pipeline {
    agent {
        docker { image 'python:3.7-slim' }
    }

    stages {
        stage('Lint') {
            sh 'make setup install lint'
        }
    }
}
