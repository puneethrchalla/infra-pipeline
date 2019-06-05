node {
    // git checkout
    git credentialsId: 'c10b1e6e-08ea-4b85-84a4-c3a9115eb5c2', url: 'git@github.com:pure-works/infra-pipeline.git'
    
    // generate chain
    sh label: '', script: '''source ./util/core-functions.sh
    calculate_layer_dependencies "${LAYERS}" ${LAYER_RIPPLE} ${MODE}'''
    
    // execute chain
    String fileContents = new File('/var/lib/jenkins/workspace/hv-infra-pipeline/chains.txt').text
    echo "${fileContents}"
    def chains = "${fileContents}".tokenize(' ')
    for(chain in chains) {
        echo "${chain}"
        def threads = [:]
        for(layer in chain.tokenize(',')) {
            def layer_name = layer
            threads["${layer}"] = {
                build job: 'run_layer', parameters: [
                    string(name: 'layer_name', value: "${layer_name}")
                    ]
            }
        }
        echo "${threads}"
        parallel threads
    }
}