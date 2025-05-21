// Jenkinsfile (Declarative Pipeline)

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
                sh "${tool 'MAVEN_HOME'}/bin/mvn clean package -DskipTests -B"
            }
        }

        stage('Test with Maven') {
            steps {
                echo 'Running tests (Maven)...'
                sh "${tool 'MAVEN_HOME'}/bin/mvn test -B"
            }
            post {
                always {
                    echo 'Publishing test results...'
                    // CORRECTION POUR JUNIT:
                    junit allowEmptyResults: true, testResults: 'target/surefire-reports/**/*.xml'
                }
            }
        }

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

        // CORRECTION: Ajout d'un bloc 'steps' même si commenté
        stage('Push Docker Image') {
            steps {
                // Décommente et configure si tu as un Docker Registry (Docker Hub, GitLab, ECR, etc.)
                // Nécessite DOCKER_CREDENTIALS_ID défini dans environment et configuré dans Jenkins
                /*
                when {
                    // Pousse uniquement pour certaines branches, ex: main/master
                    // ou si c'est un tag Git
                    anyOf { branch 'main'; branch 'master'; tag '*' }
                }
                echo "Pushing Docker image ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} and potentially :latest"
                docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) { // Pour Docker Hub
                    docker.image("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}").push()
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        docker.image("${DOCKER_IMAGE_NAME}:latest").push()
                    }
                    if (env.TAG_NAME) {
                        docker.image("${DOCKER_IMAGE_NAME}:${env.TAG_NAME}").push()
                    }
                }
                */
                echo 'Push Docker Image stage - currently commented out' // Placeholder
            }
        }

        // CORRECTION: Ajout d'un bloc 'steps' même si commenté
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
                    sh '''
                        ssh -o StrictHostKeyChecking=no user@your-server.com "
                            set -e;
                            echo '--- Logging into deployment server ---';
                            cd /path/to/your/app-deployment || exit 1;

                            echo '--- Creating/Updating .env file for docker-compose ---';
                            echo MYSQL_DATABASE=investiadb > .env
                            echo MYSQL_USER=investiauser >> .env
                            echo MYSQL_PASSWORD=${env.MYSQL_PASSWORD_SECRET_VALUE_FROM_JENKINS} >> .env
                            echo MYSQL_ROOT_PASSWORD=${env.MYSQL_ROOT_PASSWORD_SECRET_VALUE_FROM_JENKINS} >> .env
                            echo SPRING_MAIL_USERNAME=${env.SPRING_MAIL_USERNAME_SECRET} >> .env
                            echo SPRING_MAIL_PASSWORD=${env.SPRING_MAIL_PASSWORD_SECRET} >> .env
                            echo STRIPE_KEY_SECRET=${env.STRIPE_KEY_SECRET_VAL} >> .env

                            echo '--- Pulling latest application image ---';
                            docker-compose -f docker-compose.prod.yml pull app;

                            echo '--- Restarting application service ---';
                            docker-compose -f docker-compose.prod.yml up -d --force-recreate app;

                            echo '--- Cleaning up old Docker images (optional) ---';
                            docker image prune -f;
                            echo '--- Deployment finished ---';
                        "
                    '''
                }
                */
                echo 'Deploy stage - currently commented out' // Placeholder
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