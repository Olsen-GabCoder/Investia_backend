# Étape 1: Build de l'application avec Maven
FROM maven:3.8.5-openjdk-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn package -Dmaven.test.skip=true -B

# Étape 2: Création de l'image finale légère
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

COPY --from=builder /app/target/investia-0.0.1-SNAPSHOT.jar app.jar

# Variables d'environnement
# Ces valeurs peuvent être surchargées au lancement du conteneur (ex: via docker-compose ou Jenkins)

# --- Base de données (MySQL) ---
ENV SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/investiadb?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
ENV SPRING_DATASOURCE_USERNAME=investiauser
ENV SPRING_DATASOURCE_PASSWORD=secretpassword # LE COMMENTAIRE A ÉTÉ CORRECTEMENT SUPPRIMÉ DE CETTE LIGNE

# --- Configuration du serveur ---
ENV SERVER_PORT=8089
ENV SERVER_SERVLET_CONTEXT_PATH=/investiaMVC

# --- Configuration Mail (Credentials seront injectés) ---
ENV SPRING_MAIL_HOST=smtp.office365.com
ENV SPRING_MAIL_PORT=587
ENV SPRING_MAIL_USERNAME=
ENV SPRING_MAIL_PASSWORD=
ENV SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
ENV SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE=true

# --- Clés Stripe (Clé secrète sera injectée) ---
# Remplace pk_test_YOUR_PUBLIC_KEY_HERE par ta vraie clé publique Stripe
ENV STRIPE_KEY_PUBLIC=pk_test_YOUR_PUBLIC_KEY_HERE
ENV STRIPE_KEY_SECRET=

# --- Coingecko ---
ENV COINGECKO_BASE_URL=https://api.coingecko.com/api/v3

# --- Profil Spring ---
ENV SPRING_PROFILES_ACTIVE=docker

EXPOSE 8089

ENTRYPOINT ["java", "-jar", "app.jar"]