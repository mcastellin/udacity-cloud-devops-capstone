pipeline {
    agent {
        docker { 
            image 'python:3.7-stretch' 
            args '--user root'
        }
    }

    stages {
        stage('Install requirements') {
            steps {
                sh 'make install'
            }
        }
        stage('Lint') {
            steps {
                sh 'make lint'
            }
        }
    }
}
