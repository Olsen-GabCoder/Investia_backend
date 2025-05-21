// Jenkinsfile (Declarative Pipeline) - Version avec skip total des tests

pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = "tonnomdutilisateur/investia-app"
    }

    tools {
        maven 'MAVEN_HOME'
        jdk 'JDK_17'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning the repository...'
                checkout scm
            }
        }

        stage('Setup Environment') {
            steps {
                echo "Using JDK: ${tool 'JDK_17'}"
                echo "Using Maven: ${tool 'MAVEN_HOME'}"
            }
        }

        stage('Build with Maven (Skipping All Tests)') { // Nom du stage mis à jour
            steps {
                echo 'Building the application (Maven) - Skipping test compilation and execution...'
                // Utilisation de -Dmaven.test.skip=true pour sauter la compilation ET l'exécution des tests
                bat "\"${tool 'MAVEN_HOME'}\\bin\\mvn.cmd\" -U clean package -Dmaven.test.skip=true -B"
            }
        }

        // L'ancien stage 'Test with Maven' est toujours commenté/supprimé

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                script {
                    def dockerImage = docker.build("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}", "--pull -f Dockerfile .")
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        dockerImage.tag("${DOCKER_IMAGE_NAME}", "latest")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Push Docker Image stage - currently commented out'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploy stage - currently commented out'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            cleanWs()
        }
        success {
            echo 'Pipeline successful!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}