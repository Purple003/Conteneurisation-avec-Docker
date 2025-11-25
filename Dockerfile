# Étape 1 : Choisir une image de base Java
FROM eclipse-temurin:17-jdk-jammy

# Étape 2 : Définir le répertoire de travail
WORKDIR /app

# Étape 3 : Copier le JAR généré dans le conteneur
COPY target/springdocker-0.0.1-SNAPSHOT.jar app.jar

# Étape 4 : Exposer le port de l’application
EXPOSE 8080

# Étape 5 : Lancer l’application
ENTRYPOINT ["java", "-jar", "app.jar"]
