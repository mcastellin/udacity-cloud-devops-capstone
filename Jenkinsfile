pipeline {
    agent any
    stages {
        stage('Application Lint and Test') {
            agent {
                docker { 
                    image 'python:3.7-stretch' 
                    args '--user root'
                }
            }
            steps {
                sh 'make setup install'
                sh 'make lint'
                sh 'make test'
            }
        }
        stage('Docker Lint') {
            steps {
                sh 'hadolint **/Dockerfile'
            }
        }

        stage('Container build') {
            steps {
                script {
                    def capstoneImage = docker.build("mcastellin/udacity-capstone:${env.BUILD_ID}", "api")
                    /*customImage.push()*/
                    /*customImage.push('latest')*/
                } 
            }
        }
    }
}
