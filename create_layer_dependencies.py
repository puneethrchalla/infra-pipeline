import json
import os
import re
import sys

# Topological sort functions
def topological_sort(source):
    sorted = []
    visited = {}

    for key in source.keys():
        visit(key, source, sorted, visited, None)

    return sorted

def visit(key, source, sorted, visited, parent):
    in_process = -1
    level = 0

    if key in visited:
        level = visited[key]

        if level == in_process:
            raise Exception("Cyclical dependency found. Chain: %s" % visited.keys())
    else:
        level = in_process
        visited[key] = level

        if not key in source:
            raise Exception("Layer '%s' references layer '%s' which does not exist." % (parent, key))

        if key in source[key]:
            raise Exception("Layer '%s' references itself." % key)

        for dependency in source[key]:
            dep_level = visit(dependency, source, sorted, visited, key)

            level = max(level, dep_level)

        level += 1
        visited[key] = level

        while len(sorted) <= level:
            sorted.append([])

        sorted[level].append(key)

    return level

def find_terraform_remote_state(file_path, remote_state):
    # Read the file contents
    with open(file_path, 'r') as content_file:
        content = content_file.read()
        
    # This is a list of all the layers used in this file.
    layers_used = []
   
    # Find all uses of Terraform remote state
    regexp = re.compile("data\.terraform\_remote\_state\.(.*?)\.")
    
    for match in regexp.findall(content):
        layers_used.append(match)
           
    # Add all the unique layers to the remote state.
    for layer_name in layers_used:
        if not layer_name in remote_state:
            remote_state.append(layer_name)
    
# Main()
if __name__ == "__main__":
    # Find all remote state within our Terraform code.
    dependencies = {}
    feature_zone_remote_state = []

    for item in os.listdir("."):
        # If it is a folder, see if it's a layer-specific folder.
        if os.path.isdir(item) and item.startswith("layer"):
            remote_state = []

            # Find all remote state referenced by all Terraform in this folder.
            for file in os.listdir("./%s" % item):
                if file.endswith(".tf") or file.startswith("tftemplate."):
                    find_terraform_remote_state('./%s/%s' % (item, file), remote_state)

            # Remember which dependent layers this layer has.
            layer_name = item

            dependencies[layer_name] = remote_state
        elif os.path.isfile(item):
            # If it is a file, see if it's a feature-zone-specific folder.
            if item.startswith("tftemplate."):
                find_terraform_remote_state(item, feature_zone_remote_state)


    # Ensure that we have no cyclical dependencies by creating a graph of all layers and their dependencies.
    grouped = topological_sort(dependencies)

    # Put together the list of layers in the order they would be executed, so we can use it later.
    flattened = []

    for group in grouped:
        group.sort()
        flattened += group

    # Rewrite each of the layers' dependency lists so that the dependencies are in the order that those layers would be executed.
    for key in dependencies.keys():
        temp_array = dependencies[key] + []
        temp_array.sort(key=lambda layer: flattened.index(layer))
        dependencies[key] = temp_array

    # Keep track of the individual layer dependencies, but also the order in which they can be run.
    final_object = { "chain": grouped, "dependencies": dependencies }

    # Write the dependencies so we can access them later.
    dependencies_file_path = "layer_dependencies.json"

    with open(dependencies_file_path, "w") as dependencies_file:
        dependencies_file.write(json.dumps(final_object, indent=4, sort_keys=True))
