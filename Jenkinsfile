pipeline {
    agent none

    triggers {
        pollSCM('H/2 * * * *')
    }

    options {
        timestamps()
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
    }

    stages {
        stage('Checks') {
            parallel {
                stage('Terraform') {
                    agent {
                        docker {
                            image 'hashicorp/terraform:1.9.8'
                            args  '--entrypoint='
                        }
                    }
                    steps {
                        dir('terraform') {
                            sh 'terraform fmt -check -diff'
                            sh 'terraform init -backend=false'
                            sh 'terraform validate'
                        }
                    }
                }
                stage('Dockerfile lint') {
                    agent {
                        docker { image 'hadolint/hadolint:v2.12.0-debian' }
                    }
                    steps {
                        sh 'hadolint --failure-threshold error app/Dockerfile'
                    }
                }
            }
        }

        stage('Build image') {
            agent any
            steps {
                script {
                    env.IMAGE_TAG = env.GIT_COMMIT.take(7)
                }
                sh 'docker build -t payment-service:${IMAGE_TAG} app/'
            }
        }

        stage('Trivy scan') {
            agent any
            steps {
                sh '''
                  docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v trivy-cache:/root/.cache/ \
                    aquasec/trivy:0.56.2 image \
                    --exit-code 1 --severity CRITICAL --no-progress \
                    payment-service:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        success { echo "Image payment-service:${env.IMAGE_TAG} built and scanned" }
        failure { echo 'Pipeline FAILED' }
    }
}