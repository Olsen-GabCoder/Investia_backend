# Étape 1: Build de l'application avec Maven
FROM maven:3.8.5-openjdk-17 AS builder

WORKDIR /app

# Copie le pom.xml pour télécharger les dépendances (cache Maven)
COPY pom.xml .
# Utiliser -B pour le mode batch, évite les prompts interactifs
RUN mvn dependency:go-offline -B

# Copie le reste du code source
COPY src ./src

# Compile et package l'application, skippant les tests (ils seront faits dans Jenkins)
RUN mvn package -DskipTests -B

# Étape 2: Création de l'image finale légère
FROM openjdk:17-jre-slim

WORKDIR /app

# Copie le .jar packagé depuis l'étape de build
COPY --from=builder /app/target/investia-0.0.1-SNAPSHOT.jar app.jar

# Variables d'environnement pour la configuration de Spring Boot

# --- Base de données (MySQL) ---
ENV SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/investiadb?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
ENV SPRING_DATASOURCE_USERNAME=investiauser
ENV SPRING_DATASOURCE_PASSWORD=secretpassword

# --- Configuration du serveur ---
ENV SERVER_PORT=8089
ENV SERVER_SERVLET_CONTEXT_PATH=/investiaMVC

# --- Configuration Mail ---
ENV SPRING_MAIL_HOST=smtp.office365.com
ENV SPRING_MAIL_PORT=587
ENV SPRING_MAIL_USERNAME=#
ENV SPRING_MAIL_PASSWORD=#
ENV SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
ENV SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE=true

# --- Clés Stripe ---
ENV STRIPE_KEY_PUBLIC=pk_test_51R0UX4HKVFjiiCEyQJxgdCyc6CXnJCKX2SQ8vxNLNnptl05oPt6CRzxacYdYaT0eLUK08BUF9JjzO6Bn5llBiUoc00mUCuEDxm
ENV STRIPE_KEY_SECRET=#

# --- Coingecko ---
ENV COINGECKO_BASE_URL=https://api.coingecko.com/api/v3

# --- Profil Spring ---
ENV SPRING_PROFILES_ACTIVE=docker

# Expose le port sur lequel l'application écoute
EXPOSE 8089

# Commande pour lancer l'application
ENTRYPOINT ["java", "-jar", "app.jar"]
