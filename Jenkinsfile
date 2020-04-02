pipeline {
    agent any
    environment {
        apiImage = null
        apiImageName = 'mcastellin/udacity-capstone-api'
        dockerCredentialsId = 'jenkins_capstone-dockerhub'
        shortCommit = env.GIT_COMMIT.take(7)
    }
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
                    apiImage = docker.build("${apiImageName}:${shortCommit}", "api")
                } 
            }
        }

        stage('Integration testing') {
            when { branch "master" }
            steps {
                script {
                    def port = 8888
                    apiImage.withRun("-p ${port}:80") {
                        sleep 10
                        sh "curl -v http://localhost:${port}/"
                    }
                }
            }
        }

        stage('Push container') {
            when { branch "master" }
            steps {
                script {
                    docker.withRegistry('https://registry-1.docker.io/', dockerCredentialsId) {
                        apiImage.push('latest')
                    }
                }
            }
        }
    }

    post {
        cleanup {
            script {
                sh "docker rmi ${apiImageName}:${shortCommit} || true"
            }
        }
    }
}
