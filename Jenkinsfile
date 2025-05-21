// Jenkinsfile (Declarative Pipeline)

pipeline {
    agent any // Ou un agent spécifique avec Docker et Maven/Java installé

    environment {
        DOCKER_IMAGE_NAME = "tonnomdutilisateur/investia-app" // Ex: 'johndoe/investia' ou URL registry privé
        // DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        // JENKINS_MAVEN_SETTINGS_CONFIG_ID = 'maven-settings'
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
                // CORRECTION: Utiliser bat pour Windows
                // Assurer que les chemins sont corrects pour Windows si MAVEN_HOME contient des backslashes
                // La variable d'outil MAVEN_HOME devrait donner le chemin correct.
                bat "\"${tool 'MAVEN_HOME'}\\bin\\mvn.cmd\" clean package -DskipTests -B"
            }
        }

        stage('Test with Maven') {
            steps {
                echo 'Running tests (Maven)...'
                // CORRECTION: Utiliser bat pour Windows
                bat "\"${tool 'MAVEN_HOME'}\\bin\\mvn.cmd\" test -B"
            }
            post {
                always {
                    echo 'Publishing test results...'
                    junit allowEmptyResults: true, testResults: 'target/surefire-reports/**/*.xml'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                script {
                    // Docker build devrait fonctionner sur Windows si Docker Desktop est configuré pour utiliser le backend WSL2 ou Hyper-V
                    def dockerImage = docker.build("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}", "--pull -f Dockerfile .")
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        dockerImage.tag("${DOCKER_IMAGE_NAME}", "latest")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
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
                // Pour le déploiement SSH depuis Windows, tu auras besoin d'un client SSH
                // ou d'utiliser des plugins Jenkins qui gèrent cela, ou de configurer OpenSSH pour Windows.
                // L'exemple ci-dessous suppose un environnement de type Unix sur le serveur distant.
                sshagent(['your-ssh-credentials-id']) {
                    // 'bat' ici si la commande est exécutée localement pour initier quelque chose
                    // mais la commande envoyée via SSH sera exécutée sur le serveur distant
                    bat '''
                        rem Cette partie est un exemple et nécessitera une configuration SSH pour Windows
                        rem ou l'utilisation d'un plugin comme "Publish Over SSH"
                        echo "Simulating SSH deployment commands..."
                        rem ssh -o StrictHostKeyChecking=no user@your-server.com "cd /path/to/app && ./deploy-script.sh"
                    '''
                    // Exemple de ce qui serait exécuté sur le serveur distant (script Unix) :
                    // sh '''
                    //     ssh -o StrictHostKeyChecking=no user@your-server.com "
                    //         set -e;
                    //         echo '--- Logging into deployment server ---';
                    //         cd /path/to/your/app-deployment || exit 1;
                    //
                    //         echo '--- Creating/Updating .env file for docker-compose ---';
                    //         echo MYSQL_DATABASE=investiadb > .env
                    //         # ... (autres variables .env)
                    //
                    //         echo '--- Pulling latest application image ---';
                    //         docker-compose -f docker-compose.prod.yml pull app;
                    //
                    //         echo '--- Restarting application service ---';
                    //         docker-compose -f docker-compose.prod.yml up -d --force-recreate app;
                    //
                    //         echo '--- Cleaning up old Docker images (optional) ---';
                    //         docker image prune -f;
                    //         echo '--- Deployment finished ---';
                    //     "
                    // '''
                }
                */
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