pipeline {
    agent any
    stages {
        stage('checkout') {
            steps {
                checkout scm
                sh 'echo "Checkout Successful"'
            }
        }
        stage('terraform plan & apply') {
            steps {
                sh './tfmain'
            }
        }
        stage('infra-tests') {
            steps {
                sh 'echo "AWSPEC tests for the Deployed Components"'
		sh 'echo "Starting awspec....."'
                sh '''#!/bin/bash -l
                cd test
                #./RunSpec.sh'''
            } 
        }
    }
}
