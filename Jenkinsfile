pipeline {
    agent any
    environment {
        dockerCredentialsId = 'capstone_docker'
        kubectlCredentialsId = 'capstone_kubectl'
        
        shortCommit = env.GIT_COMMIT.take(7)
        apiImageName = 'mcastellin/udacity-capstone-api'
        isRelease = false
        apiImage = null
        candidate = null
        nextCandidate = null
    }
    stages {
        stage('Application Lint & Test') {
            agent {
                docker { 
                    image 'python:3.7-stretch' 
                    args '--user root'
                }
            }
            steps {
                sh 'make setup install'
                sh 'make lint-python'
                sh 'make test'
            }
        }

        stage('Docker & HTML Lint') {
            steps {
                sh 'make lint-docker'
                sh 'make lint-html'
            }
        }

        stage('Container build') {
            steps {
                script {
                    apiImage = docker.build("${apiImageName}:${shortCommit}", "api")
                } 
            }
        }

        stage('Container security scan') {
            steps {
                script {
                    aquaMicroscanner imageName: "${apiImageName}:${shortCommit}", notCompliesCmd: 'exit 1', onDisallowed: 'ignore'
                } 
            }
        }

        stage('Integration testing') {
            when { branch "master" }
            steps {
                script {
                    def port = 8888
                    apiImage.withRun("-p ${port}:8080") {
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
                        apiImage.push()
                    }
                }
            }
        }

        stage('Update cluster') {
            when { branch "master" }
            steps {
                script {
                    isRelease = true // flag that we are performing a release for post handling.

                    withKubeConfig([
                        credentialsId: kubectlCredentialsId,
                        serverUrl: env.EKS_API_URL
                    ]) {
                        candidate = sh(returnStdout: true, 
                            script: 'kubectl get service capstone-api-svc -o go-template --template \'{{.spec.selector.release}}{{"\\n"}}\'')
                            .trim()

                        nextCandidate = candidate == "blue" ? "green" : "blue"

                        echo "Next release is ${nextCandidate}"

                        sh "tagid=${shortCommit} envsubst < k8s/${nextCandidate}-deployment.yaml | kubectl apply -f -"

                        def status = null
                        def remaining = 5
                        while(remaining > 0 && status != "200") {
                           sleep 10
                           status = sh(returnStdout: true,
                                script: "curl -w \"%{http_code}\" -s -o /dev/null ${env.EKS_PUBLIC_DNS}/${nextCandidate}/api")
                                .trim()
                        }
                        if(status != "200") {
                            error("Deployment failed to respond with successful code 200, got $status instead.")
                        }
                    }
                }
            }
        }
        
        stage('Smoke tests') {
            when { branch "master" }
            steps {
                script {
                    withKubeConfig([
                        credentialsId: kubectlCredentialsId,
                        serverUrl: env.EKS_API_URL
                    ]) {
                        echo "TODO: smoke testing"
                    }
                }
            }
        }

        stage('Promote release') {
            when { branch "master" }
            steps {
                script {
                    withKubeConfig([
                        credentialsId: kubectlCredentialsId,
                        serverUrl: env.EKS_API_URL
                    ]) {
                        sh "kubectl set selector service/capstone-api-svc release=${nextCandidate},app=capstone-api -n default" 
                        sh """
                            kubectl delete deployment ${candidate}-capstone-api -n default || true
                            kubectl delete hpa ${candidate}-capstone-api -n default || true
                        """
                    }
                }
            }
        }
    }

    post {
        failure {
            script {
                withKubeConfig([
                    credentialsId: kubectlCredentialsId,
                    serverUrl: env.EKS_API_URL
                ]) {
                    /*
                        If a current release candidate has been identified, rolling back the published release to the existing candidate.
                    */
                    if(candidate == "blue" || candidate == "green") {
                        sh "kubectl set selector service/capstone-api-svc release=${candidate},app=capstone-api -n default" 
                    }
                }
            }
        }

        success {
            script {
                if(isRelease == true) {
                    docker.withRegistry('https://registry-1.docker.io/', dockerCredentialsId) {
                        apiImage.push('latest')
                    }
                }
            }
        }

        cleanup {
            script {
                sh "docker rmi ${apiImageName}:${shortCommit} || true"
            }
        }
    }
}
