# Étape 1: Build de l'application avec Maven
FROM maven:3.8.5-openjdk-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn package -DskipTests -B # -DskipTests est déjà dans le Jenkinsfile, mais le laisser ici est sans danger

# Étape 2: Création de l'image finale légère
# Utilisation d'une image Eclipse Temurin JRE basée sur Ubuntu Jammy
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

COPY --from=builder /app/target/investia-0.0.1-SNAPSHOT.jar app.jar

# Variables d'environnement (ajuste selon tes besoins et ce qui est fourni par Jenkins/docker-compose)
ENV SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/investiadb?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
ENV SPRING_DATASOURCE_USERNAME=investiauser
ENV SPRING_DATASOURCE_PASSWORD=secretpassword
ENV SERVER_PORT=8089
ENV SERVER_SERVLET_CONTEXT_PATH=/investiaMVC
ENV SPRING_MAIL_HOST=smtp.office365.com
ENV SPRING_MAIL_PORT=587
ENV SPRING_MAIL_USERNAME= # Sera surchargé
ENV SPRING_MAIL_PASSWORD= # Sera surchargé
ENV SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
ENV SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE=true
ENV STRIPE_KEY_PUBLIC=pk_test_YOUR_PUBLIC_KEY # Clé publique
ENV STRIPE_KEY_SECRET= # Sera surchargé
ENV COINGECKO_BASE_URL=https://api.coingecko.com/api/v3
ENV SPRING_PROFILES_ACTIVE=docker

EXPOSE 8089

ENTRYPOINT ["java", "-jar", "app.jar"]