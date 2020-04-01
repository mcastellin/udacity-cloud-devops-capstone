pipeline {
    agent {
        docker { image 'python:3.7-slim' }
    }

    stages {
        stage('Lint') {
            steps {
                sh 'make setup install lint'
            }
        }
    }
}
