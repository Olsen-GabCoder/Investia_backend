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
                // S'assurer que les bons outils sont sur le PATH si configurés via 'tools'
                // sh "mvn -v"
                // sh "java -version"
                echo "Using JDK: ${tool 'JDK_17'}"
                echo "Using Maven: ${tool 'MAVEN_HOME'}"
            }
        }

        stage('Build with Maven') {
            steps {
                echo 'Building the application (Maven)...'
                // Utilise les outils configurés via la section 'tools'
                // Le -B est pour le mode batch (non-interactif)
                // Le -U force la mise à jour des snapshots/releases si nécessaire
                // mvn -s "${tool JENKINS_MAVEN_SETTINGS_CONFIG_ID}" si tu utilises un settings.xml managé
                sh "${tool 'MAVEN_HOME'}/bin/mvn clean package -DskipTests -B"
                // Alternative si tu préfères utiliser un agent Docker pour le build :
                /*
                docker.image('maven:3.8.5-openjdk-17').inside {
                    sh 'mvn clean package -DskipTests -B'
                }
                */
            }
        }

        stage('Test with Maven') {
            steps {
                echo 'Running tests (Maven)...'
                // Les tests utilisent H2 (base de données en mémoire), donc pas besoin de service externe ici.
                sh "${tool 'MAVEN_HOME'}/bin/mvn test -B"
            }
            post {
                always {
                    echo 'Publishing test results...'
                    junit étapes: [[allowEmptyResults: true, testResults: 'target/surefire-reports/**/*.xml']]
                }
            }
        }

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
            // Décommente et configure si tu as un Docker Registry (Docker Hub, GitLab, ECR, etc.)
            // Nécessite DOCKER_CREDENTIALS_ID défini dans environment et configuré dans Jenkins
            /*
            when {
                // Pousse uniquement pour certaines branches, ex: main/master
                // ou si c'est un tag Git
                anyOf { branch 'main'; branch 'master'; tag '*' }
            }
            steps {
                echo "Pushing Docker image ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} and potentially :latest"
                docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) { // Pour Docker Hub
                    // Pousse le tag avec le numéro de build
                    docker.image("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}").push()

                    // Pousse le tag 'latest' si c'est la branche principale
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        docker.image("${DOCKER_IMAGE_NAME}:latest").push()
                    }
                    // Si c'est un tag Git, tu peux aussi pousser une image avec ce tag Git
                    if (env.TAG_NAME) {
                        docker.image("${DOCKER_IMAGE_NAME}:${env.TAG_NAME}").push()
                    }
                }
            }
            */
        }

        stage('Deploy') {
            // Décommente et adapte à ton environnement de déploiement
            /*
            when {
                // Déploie uniquement pour la branche principale après un push réussi
                anyOf { branch 'main'; branch 'master' }
            }
            environment {
                // Récupère les secrets depuis les credentials Jenkins
                // Assure-toi que ces credentials existent dans Jenkins (type "Secret text" ou "Username with password")
                SPRING_MAIL_USERNAME_SECRET = credentials('jenkins-mail-username-id')
                SPRING_MAIL_PASSWORD_SECRET = credentials('jenkins-mail-password-id')
                STRIPE_KEY_SECRET_VAL = credentials('jenkins-stripe-secret-key-id')
                // Pour la base de données, si tu ne veux pas les mettre en dur dans docker-compose sur le serveur
                // MYSQL_USER_SECRET = credentials('jenkins-db-user-id')
                // MYSQL_PASSWORD_SECRET = credentials('jenkins-db-password-id')
                // MYSQL_ROOT_PASSWORD_SECRET = credentials('jenkins-db-root-password-id')
            }
            steps {
                echo 'Deploying application...'
                // Exemple pour un déploiement avec docker-compose sur un serveur distant via SSH
                // 'your-ssh-credentials-id' sont les credentials SSH configurés dans Jenkins
                sshagent(['your-ssh-credentials-id']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no user@your-server.com "
                            set -e; # Arrête le script en cas d'erreur
                            echo '--- Logging into deployment server ---';
                            cd /path/to/your/app-deployment || exit 1; # Chemin où se trouve ton docker-compose.yml pour le déploiement

                            echo '--- Creating/Updating .env file for docker-compose ---';
                            # Crée ou met à jour un fichier .env pour les secrets
                            # docker-compose lira automatiquement ce fichier
                            # ATTENTION: Assure-toi que les variables SPRING_..._SECRET sont bien les valeurs et non les ID
                            echo MYSQL_DATABASE=investiadb > .env
                            echo MYSQL_USER=investiauser >> .env # Ou $MYSQL_USER_SECRET si tu le passes de Jenkins
                            echo MYSQL_PASSWORD=${MYSQL_PASSWORD_SECRET_VALUE_FROM_JENKINS} >> .env # Récupère la valeur
                            echo MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD_SECRET_VALUE_FROM_JENKINS} >> .env

                            echo SPRING_MAIL_USERNAME=${SPRING_MAIL_USERNAME_SECRET} >> .env
                            echo SPRING_MAIL_PASSWORD=${SPRING_MAIL_PASSWORD_SECRET} >> .env
                            echo STRIPE_KEY_SECRET=${STRIPE_KEY_SECRET_VAL} >> .env
                            # Ajoute d'autres variables d'environnement nécessaires

                            echo '--- Pulling latest application image ---';
                            # Assure-toi que le docker-compose.yml sur le serveur utilise l'image poussée
                            # ex: image: ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ou ${DOCKER_IMAGE_NAME}:latest
                            docker-compose -f docker-compose.prod.yml pull app; # Utilise un docker-compose spécifique pour la prod si besoin

                            echo '--- Restarting application service ---';
                            docker-compose -f docker-compose.prod.yml up -d --force-recreate app;

                            echo '--- Cleaning up old Docker images (optional) ---';
                            docker image prune -f;

                            echo '--- Deployment finished ---';
                        "
                    '''
                }
            }
            */
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