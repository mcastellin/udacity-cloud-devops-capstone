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
            steps {
                script {
                    def port = 8888
                    apiImage.withRun("-p ${port}:8080") {
                        sleep 10
                        sh """
                        curl -v http://localhost:${port}/
                        curl -v -XPOST -H 'Content-Type: application/json' -d '{"text": "tomorrow"}' http://localhost:${port}/translate
                        """
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

                        echo "waiting for pods to be ready..."

                        def attempts = 0
                        def status = 'nok'
                        while(attempts < 10 && status != 'ok') {
                            try {
                                sh "kubectl get pods -l app=capstone-api -l release=${nextCandidate} -o jsonpath='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' | grep 'Ready=True'"
                                status = 'ok'
                            } catch (Exception e) {
                                attempts++
                                sleep 5
                            }
                        }
                        if(status != 'ok') {
                            error("Deployment failed liveness check after ${attempts} attempts. Rolling back.")
                        }
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
                    }
                }
            }
        }

        stage('Smoke tests') {
            when { branch "master" }
            agent {
                docker { 
                    image 'python:3.7-stretch' 
                    args '--user root'
                }
            }
            steps {
                sh 'pip install locust'
                sh "locust -f locustfile.py --no-web -c 3 -r 1 --run-time 20s --host '${env.EKS_PUBLIC_DNS}'"
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

                    withKubeConfig([
                        credentialsId: kubectlCredentialsId,
                        serverUrl: env.EKS_API_URL
                    ]) {
                        /* Deleting old release after successful deployment */
                        sh """
                            kubectl delete deployment ${candidate}-capstone-api -n default || true
                            kubectl delete hpa ${candidate}-capstone-api -n default || true
                        """
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
