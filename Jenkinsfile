pipeline {
    agent none                       // глобального агента нет, каждый stage выбирает свой

    triggers {
        pollSCM('H/2 * * * *')       // проверять репозиторий каждые ~2 минуты
    }

    options {
        timestamps()                 // время в каждой строке лога
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    stages {
        stage('Terraform fmt & validate') {
            agent {
                docker {
                    image 'hashicorp/terraform:1.9.8'
                    args  '--entrypoint='   // у образа entrypoint = terraform, сбрасываем
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
    }

    post {
        success { echo 'Terraform check passed' }
        failure { echo 'Terraform check FAILED' }
    }
}