// Jenkinsfile (Declarative Pipeline) - Version sans étape de Test Maven

pipeline {
    agent any // Ou un agent spécifique avec Docker et Maven/Java installé

    environment {
        DOCKER_IMAGE_NAME = "tonnomdutilisateur/investia-app" // Ex: 'johndoe/investia' ou URL registry privé
        // DOCKER_CREDENTIALS_ID = 'dockerhub-credentials' // ID des credentials Docker dans Jenkins si registry privé/DockerHub
        // JENKINS_MAVEN_SETTINGS_CONFIG_ID = 'maven-settings' // Si tu as un fichier settings.xml géré par Jenkins
    }

    tools {
        maven 'MAVEN_HOME' // Nom de la configuration Maven dans "Global Tool Configuration" de Jenkins
        jdk 'JDK_17'       // Nom de la configuration JDK dans "Global Tool Configuration" de Jenkins
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

        stage('Build with Maven') {
            steps {
                echo 'Building the application (Maven)...'
                // L'option -U force la mise à jour des dépendances
                // -DskipTests est déjà là, ce qui est bien car on enlève le stage de test dédié
                bat "\"${tool 'MAVEN_HOME'}\\bin\\mvn.cmd\" -U clean package -DskipTests -B"
            }
        }

        // STAGE 'Test with Maven' SUPPRIMÉ
        /*
        stage('Test with Maven') {
            steps {
                echo 'Running tests (Maven)...'
                bat "\"${tool 'MAVEN_HOME'}\\bin\\mvn.cmd\" -U test -B"
            }
            post {
                always {
                    echo 'Publishing test results...'
                    junit allowEmptyResults: true, testResults: 'target/surefire-reports/** /*.xml' // Note: this line would cause error if tests are skipped
                }
            }
        }
        */

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                // Le Dockerfile est à la racine du projet
                script {
                    def dockerImage = docker.build("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}", "--pull -f Dockerfile .")
                    // Tagger aussi comme 'latest' pour la branche principale par exemple
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        dockerImage.tag("${DOCKER_IMAGE_NAME}", "latest")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                // Décommente et configure si tu as un Docker Registry (Docker Hub, GitLab, ECR, etc.)
                /*
                when {
                    anyOf { branch 'main'; branch 'master'; tag '*' }
                }
                echo "Pushing Docker image ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} and potentially :latest"
                docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                    docker.image("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}").push()
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        docker.image("${DOCKER_IMAGE_NAME}:latest").push()
                    }
                    if (env.TAG_NAME) {
                        docker.image("${DOCKER_IMAGE_NAME}:${env.TAG_NAME}").push()
                    }
                }
                */
                echo 'Push Docker Image stage - currently commented out'
            }
        }

        stage('Deploy') {
            steps {
                // Décommente et adapte à ton environnement de déploiement
                /*
                when {
                    anyOf { branch 'main'; branch 'master' }
                }
                environment {
                    SPRING_MAIL_USERNAME_SECRET = credentials('jenkins-mail-username-id')
                    SPRING_MAIL_PASSWORD_SECRET = credentials('jenkins-mail-password-id')
                    STRIPE_KEY_SECRET_VAL = credentials('jenkins-stripe-secret-key-id')
                }
                echo 'Deploying application...'
                sshagent(['your-ssh-credentials-id']) {
                    bat '''
                        rem Cette partie est un exemple et nécessitera une configuration SSH pour Windows
                        rem ou l'utilisation d'un plugin comme "Publish Over SSH"
                        echo "Simulating SSH deployment commands..."
                        rem ssh -o StrictHostKeyChecking=no user@your-server.com "cd /path/to/app && ./deploy-script.sh"
                    '''
                }
                */
                echo 'Deploy stage - currently commented out'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            cleanWs() // Nettoie l'espace de travail Jenkins après le build
        }
        success {
            echo 'Pipeline successful!'
            // Notifier le succès (ex: mail, Slack)
        }
        failure {
            echo 'Pipeline failed.'
            // Notifier l'échec
        }
    }
}