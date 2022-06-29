def my_tmp_var  = ""
def image_name = "example-app"

pipeline {
    agent any

    environment {
        MY_ENV = "test env 01"
        REGISTRY_NAME = "${params.AWS_ACCOUNT}.dkr.ecr.${params.AWS_REGION}.amazonaws.com"
    }

    parameters {
        string(
            name: 'IMAGE_NAME',
            defaultValue: image_name,
            description: 'Image name'
        )
        
        choice(
            name: "AWS_REGION",
            choices: ["us-east-1", "us-west-1"],
            description: "AWS region name",
        )
        
        string(
            name: "AWS_ACCOUNT",
            defaultValue: "507676015690",
            description: 'AWS_ACCOUNT_ID'
        )
    }

    stages {
        stage("Pre-check") {
            steps {
                script {
                    image_name = "example_app"
                    if (!params.IMAGE_NAME.isEmpty()) {
                        image_name = params.IMAGE_NAME
                    }
                }
            }
        }
        
        stage("SCM") {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[
                        name: '*/master'
                    ]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/vladyslav-tripatkhi/react-redux-realworld-example-app.git'
                    ]]])
            }
        }

        stage("Build") {
            steps {
                echo "Building; Build ID: ${env.BUILD_ID}"
                // sh "docker build -t ${params.IMAGE_NAME}:${env.BUILD_ID} ."
                script {
                    my_tmp_var = "Hello! ${env.MY_ENV}"
                    docker.build("${env.REGISTRY_NAME}/${image_name}:${env.BUILD_ID}")
                }

                echo "Hello from ${my_tmp_var}"
            }
        }

        stage("Push") {
            parallel {
                stage("Push to us-east-1") {
                    steps {
                        script {
                            def region = "us-east-1"
                            echo "Deploying ${env.MY_ENV} to ${region}"
                            def registry_name = "${params.AWS_ACCOUNT}.dkr.ecr.${region}.amazonaws.com"
                            docker.withRegistry("https://${registry_name}", "ecr:${region}:jenkins-ecr-role") {
                                docker.image("${registry_name}/${image_name}:${env.BUILD_ID}").push()
                            }
                        }
                    }
                }

                stage("Push to us-west-1") {
                    steps {
                        script {
                            def region = "us-west-1"
                            echo "Deploying ${env.MY_ENV} to ${region}"
                            def registry_name = "${params.AWS_ACCOUNT}.dkr.ecr.${region}.amazonaws.com"
                            sh "docker tag ${env.REGISTRY_NAME}/${image_name}:${env.BUILD_ID} ${registry_name}/${image_name}:${env.BUILD_ID}"
                            docker.withRegistry("https://${registry_name}", "ecr:${region}:jenkins-ecr-role") {
                                docker.image("${registry_name}/${image_name}:${env.BUILD_ID}").push()
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
