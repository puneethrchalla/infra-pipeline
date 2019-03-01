node {
    def chains = 'hello,puneeth,karim,chacha world,reddy there,modi'.tokenize(' ')
    for(chain in chains) {
        echo "${chain}"
        def threads = [:]
        for(layer in chain.tokenize(',')) {
            def layer_name = layer
            echo "Executing ${layer}"
            threads["${layer}"] = {
                build job: 'print-layer', parameters: [
                    string(name: 'layer_name', value: "${layer_name}")
                    ]
            }
        }
        echo "${threads}"
        parallel threads
    }
}