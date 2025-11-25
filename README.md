# TP 14 : Conteneurisation avec Docker - Spring Boot

## Description
Ce projet démontre la conteneurisation d'une application Spring Boot avec Docker et Docker Compose, incluant une base de données MySQL.

## Objectifs
- Construire une image Docker à partir d'un projet Spring Boot
- Exécuter et gérer un conteneur d'application
- Configurer les variables d'environnement pour le conteneur
- Déployer une base de données MySQL dans un second conteneur
- Établir la communication entre conteneurs via Docker Compose

## Technologies utilisées
- **Java 17**
- **Spring Boot 3.2.5**
- **Docker & Docker Compose**
- **MySQL 8.0**
- **Maven**

## Dépendances Spring Boot
- Spring Web
- Spring Data JPA
- MySQL Driver
- Lombok

---

## Étape 1 : Préparation du projet Spring Boot

### Configuration
Le projet a été créé via [Spring Initializr](https://start.spring.io) avec les paramètres suivants :
- **Group** : `ma.ens`
- **Artifact** : `springdocker`
- **Java Version** : 17

### Fichier `application.properties`
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/demo_db?createDatabaseIfNotExist=true
spring.datasource.username=root
spring.datasource.password=1234
spring.jpa.hibernate.ddl-auto=update
server.port=8080
```

### Compilation du projet
```bash
mvn clean package
```

### Structure du projet
<img width="580" height="634" alt="Screenshot 2025-11-26 001152" src="https://github.com/user-attachments/assets/4c77151b-63a8-419f-872b-17ca9325e520" />

---

## Étape 2 : Écriture du Dockerfile

Le `Dockerfile` permet de créer une image Docker de l'application :

```dockerfile
# Étape 1 : Choisir une image de base Java
FROM eclipse-temurin:17-jdk-jammy

# Étape 2 : Définir le répertoire de travail
WORKDIR /app

# Étape 3 : Copier le JAR généré dans le conteneur
COPY target/springdocker-0.0.1-SNAPSHOT.jar app.jar

# Étape 4 : Exposer le port de l'application
EXPOSE 8080

# Étape 5 : Lancer l'application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Explications
- **FROM** : Image de base (Eclipse Temurin remplace l'ancien OpenJDK)
- **WORKDIR** : Répertoire de travail dans le conteneur
- **COPY** : Transfert du JAR vers le conteneur
- **EXPOSE** : Port utilisé par l'application
- **ENTRYPOINT** : Commande de démarrage

---

## Étape 3 : Construction et exécution de l'image Docker

### Construction de l'image
```bash
docker build -t ens/springdocker:1.0 .
```

### Vérification de l'image
```bash
docker images
```

### Screenshot : docker images
<img width="986" height="227" alt="Screenshot 2025-11-26 001340" src="https://github.com/user-attachments/assets/8daa5b9e-50bc-4e59-9a80-ad874db5ab7e" />

### Exécution du conteneur
```bash
docker run -d -p 8080:8080 --name spring-app ens/springdocker:1.0
```

### Vérification des conteneurs actifs
```bash
docker ps
```

### Screenshot : docker ps
<img width="1770" height="301" alt="image" src="https://github.com/user-attachments/assets/d81a8c2d-3c1a-4009-80d5-ff3aa96869a6" />

### Consultation des logs
```bash
docker logs -f spring-app
```

### Arrêt et suppression du conteneur
```bash
docker stop spring-app
docker rm spring-app
```

---

## Étape 4 : Ajout d'un conteneur MySQL avec Docker Compose

Le fichier `docker-compose.yml` orchestre l'application et la base de données :

```yaml
version: '3.8'
services:
  mysql-db:
    image: mysql:8.0
    container_name: mysql-db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: 1234
      MYSQL_DATABASE: demo_db
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql

  spring-app:
    image: ens/springdocker:1.0
    container_name: spring-app
    restart: always
    depends_on:
      - mysql-db
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://mysql-db:3306/demo_db?createDatabaseIfNotExist=true
      - SPRING_DATASOURCE_USERNAME=root
      - SPRING_DATASOURCE_PASSWORD=1234
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
    ports:
      - "8080:8080"

volumes:
  mysql-data:
```

### Explications
- **services** : Définit les deux conteneurs (MySQL et Spring Boot)
- **depends_on** : Garantit l'ordre de démarrage
- **environment** : Variables d'environnement pour la configuration
- **volumes** : Persistance des données MySQL
- **restart: always** : Redémarrage automatique en cas d'échec

---

## Étape 5 : Exécution avec Docker Compose

### Démarrage des conteneurs
```bash
docker-compose up -d
```

### Screenshot : docker-compose up
<img width="1279" height="213" alt="image" src="https://github.com/user-attachments/assets/7dc6cd58-77b1-43a8-a233-0b355fd5093b" />

### Vérification des services actifs
```bash
docker ps
```

### Screenshot : docker ps (les 2 conteneurs)
<img width="1770" height="277" alt="image" src="https://github.com/user-attachments/assets/5203338f-5aa5-48ea-aebf-e12a3fc7372a" />

### Affichage des logs
```bash
docker-compose logs -f
```

Ou pour un service spécifique :
```bash
docker-compose logs -f spring-app
```

### Screenshot : Logs de l'application
<img width="1351" height="409" alt="image" src="https://github.com/user-attachments/assets/888883cf-7def-49bc-817a-e047380c893c" />

### Arrêt de l'environnement
```bash
docker-compose down
```
<img width="1784" height="247" alt="image" src="https://github.com/user-attachments/assets/498a5848-9d34-4ece-ae78-e17d54cf1aa6" />

---

##  Étape 6 : Validation

### Vérifications effectuées
- L'application Spring Boot communique correctement avec MySQL
- Les données persistent après redémarrage des conteneurs (grâce au volume)
- Les ports 8080 et 3306 sont bien exposés
- L'application démarre automatiquement après la base de données



---

## Commandes utiles

### Docker
```bash
# Lister les images
docker images

# Lister les conteneurs actifs
docker ps

# Lister tous les conteneurs (y compris arrêtés)
docker ps -a

# Voir les logs d'un conteneur
docker logs <container-name>

# Arrêter un conteneur
docker stop <container-name>

# Supprimer un conteneur
docker rm <container-name>

# Supprimer une image
docker rmi <image-name>
```

### Docker Compose
```bash
# Démarrer les services
docker-compose up -d

# Arrêter les services
docker-compose down

# Voir les logs
docker-compose logs -f

# Redémarrer un service
docker-compose restart <service-name>

# Reconstruire les images
docker-compose build
```

---

## Extensions possibles

### 1. Ajouter phpMyAdmin
Ajouter ce service dans `docker-compose.yml` :
```yaml
phpmyadmin:
  image: phpmyadmin/phpmyadmin
  container_name: phpmyadmin
  environment:
    PMA_HOST: mysql-db
    PMA_PORT: 3306
  ports:
    - "8081:80"
  depends_on:
    - mysql-db
```

### 2. Publier sur Docker Hub
```bash
docker tag ens/springdocker:1.0 username/springdocker:1.0
docker push username/springdocker:1.0
```

### 3. Intégration CI/CD
- Pipeline Jenkins
- GitLab CI
- GitHub Actions

---

## Compétences acquises

| Compétence | Description |
|------------|-------------|
| **Dockerfile** | Construction d'images Docker à partir d'un projet Spring Boot |
| **Commandes Docker** | Gestion des conteneurs, images et logs |
| **Variables d'environnement** | Configuration dynamique des services |
| **Docker Compose** | Déploiement multi-conteneurs orchestré |
| **Persistance des données** | Utilisation de volumes pour MySQL |

---

## 👤 Auteur
- **Nom** : Arroche Aya

