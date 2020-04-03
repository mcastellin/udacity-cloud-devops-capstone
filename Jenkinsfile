pipeline {
    agent any
    environment {
        shortCommit = env.GIT_COMMIT.take(7)
        isRelease = false
        apiImage = null
        apiImageName = 'mcastellin/udacity-capstone-api'
        dockerCredentialsId = 'jenkins_capstone-dockerhub'
        kubectlCredentialsId = 'jenkins_capstone-kubectl'
        k8sAPIServerId = 'jenkins_capstone-k8s-api'
        publicDNSNameCredentialsId = 'jenkins_capstone-public-dns'
        publicDNSName = null
        candidate = null
        nextCandidate = null
        k8sAPIServer = null
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
                    withCredentials([string(credentialsId: k8sAPIServerId, variable: 'k8sAPIServerVar'),
                    string(credentialsId: publicDNSNameCredentialsId, variable: 'publicDNSNameVar')]) {
                        // Storing variables at a global level
                        k8sAPIServer = k8sAPIServerVar
                        publicDNSName = publicDNSNameVar

                        withKubeConfig([
                            credentialsId: kubectlCredentialsId,
                            serverUrl: k8sAPIServer
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
                                    script: "curl -w \"%{http_code}\" -s -o /dev/null ${publicDNSName}/${nextCandidate}/api")
                                    .trim()
                            }
                            if(status != "200") {
                                error("Deployment failed to respond with successful code 200, got $status instead.")
                            }
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
                        serverUrl: k8sAPIServer
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
                        serverUrl: k8sAPIServer
                    ]) {
                        sh "kubectl set selector service/capstone-api-svc release=${nextCandidate},app=capstone-api -n default" 
                        sh "kubectl delete deployment ${candidate}-capstone-api -n default || true"
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
                    serverUrl: k8sAPIServer
                ]) {
                    /*
                        If a current release candidate has been identified, rolling back the published release to the existing candidate.
                    */
                    if(candidate != null) {
                        sh "kubectl set selector service/capstone-api-svc release=${candidate},app=capstone-api -n default" 
                    }
                }
            }
        }

        success {
            script {
                if(isRelease) {
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
