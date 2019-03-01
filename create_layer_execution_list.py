import json
import os
import re
import sys

def calculate_upstream(layer, dependencies, layers):
    if layer not in layers:
        layers.append(layer)      
    # For each dependency of this service, calculate its upstream.
    for dependency in dependencies[layer]:
        calculate_upstream(dependency, dependencies, layers)
    
def calculate_downstream(layer, dependencies, layers):
    if layer not in layers:
        layers.append(layer)
        
    # For each layer that has a dependency on this one, calculate its downstream.
    for key in dependencies:
        if layer in dependencies[key]:
            calculate_downstream(key, dependencies, layers)
    
# Main()
if __name__ == "__main__":
    # Parameters
    layer_csv = sys.argv[1]
    mode = sys.argv[2]
    layer_ripple = sys.argv[3]
       
    # Load the JSON file that has the layer dependencies figured out.
    with open("layer_dependencies.json", "r") as json_file:
        layer_json = json.loads(json_file.read())

    # This is the list of layers that ultimately gets run.
    layers = []
        
    # Based on the list of layers passed in, and the ripple, calculate the complete list of what to run.
    # If no layers were passed, then add in all layers to process.
    layers_to_process = []
    
    if layer_csv == "":
        for layer in layer_json["dependencies"]:
            layers_to_process.append(layer)
    else:
        layers_to_process += layer_csv.split(",")        
   
    for layer in layers_to_process:
        # If there are no ripple options specified, just process the layer.
        if len(layer_ripple) == 1 and layer_ripple[0] == "":
            layers.append(layer)

        if layer_ripple == "upstream":
            calculate_upstream(layer, layer_json["dependencies"], layers)
        
        if layer_ripple == "downstream":
            calculate_downstream(layer, layer_json["dependencies"], layers)

    # Group the layers to run into a chain based on the original chain that exists.
    layer_chain = []
    
    for chain in layer_json["chain"]:
        local_chain = []
        
        for layer in layers:
            if layer in chain:
                local_chain.append(layer)
                
        if len(local_chain) > 0:
            local_chain.sort()
            layer_chain.append(local_chain)
            
    # If we are terminating, then reverse the layer list.    
    if mode == "terminate":
        layer_chain.reverse()
  
    # Write out the layer chain. The format will be "a,b,c d,e f", where the groups are separated by a single space,
    # and the layers within each group are a CSV.
    chain_string = ""
    
    for chain in layer_chain:
        chain_string = "%s %s" % (chain_string, ",".join(chain))
    
    print(chain_string.strip())