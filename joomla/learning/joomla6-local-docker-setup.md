# Joomla 6 Local Setup with Docker

A beginner-friendly guide to create a reusable Docker wrapper, add the Joomla source code, run the installer, and generate `configuration.php`.

## Table of Contents

- [1. Setup Flow](#1-setup-flow)
- [2. Project Structure](#2-project-structure)
- [3. Create the Wrapper](#3-create-the-wrapper)
- [4. Download and Add Joomla](#4-download-and-add-joomla)
- [5. Understand the Installation Folder](#5-understand-the-installation-folder)
- [6. Start the Project](#6-start-the-project)
- [7. Complete the Joomla Installer](#7-complete-the-joomla-installer)
- [8. How configuration.php Is Created](#8-how-configurationphp-is-created)
- [9. Fix configuration.php Write Errors](#9-fix-configurationphp-write-errors)
- [10. Access the Website](#10-access-the-website)
- [11. Reset the Installation](#11-reset-the-installation)
- [12. Final Checklist](#12-final-checklist)

---

## 1. Setup Flow

```text
Create Docker wrapper
→ Download Joomla Full Package
→ Extract Joomla into src/
→ Start Docker containers
→ Open Joomla Installer
→ Configure site and database
→ Joomla creates database tables
→ Joomla creates configuration.php
→ Open the website and Administrator panel
```

---

## 2. Project Structure

```text
joomla6-wrapper/
├── docker/
│   ├── apache/
│   │   └── 000-default.conf
│   └── php/
│       └── php.ini
├── mysql/
│   └── init/
├── src/
├── .env
├── .gitignore
├── Dockerfile
└── docker-compose.yml
```

The Docker files are the reusable wrapper. The Joomla source code is placed inside `src/`.

---

## 3. Create the Wrapper

### 3.1 Create folders

```bash
mkdir -p joomla6-wrapper/{docker/apache,docker/php,mysql/init,src}
cd joomla6-wrapper
```

### 3.2 Create `.env`

```env
APP_PORT=8080
PMA_PORT=8081
MYSQL_PORT=3307

MYSQL_DATABASE=joomla6
MYSQL_USER=joomla
MYSQL_PASSWORD=joomla_password
MYSQL_ROOT_PASSWORD=root_password
```

### 3.3 Create `Dockerfile`

```dockerfile
FROM php:8.4-apache

RUN apt-get update \
    && apt-get install -y \
        unzip \
        libzip-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli pdo_mysql intl gd zip opcache \
    && a2enmod rewrite headers expires \
    && rm -rf /var/lib/apt/lists/*

COPY docker/php/php.ini /usr/local/etc/php/conf.d/joomla.ini

WORKDIR /var/www/html
```

### 3.4 Create `docker/php/php.ini`

```ini
memory_limit = 512M
upload_max_filesize = 128M
post_max_size = 128M
max_execution_time = 300
max_input_vars = 5000
date.timezone = Asia/Ho_Chi_Minh
display_errors = On
error_reporting = E_ALL
```

Use `display_errors = On` only for local development.

### 3.5 Create `docker/apache/000-default.conf`

```apache
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

### 3.6 Create `docker-compose.yml`

```yaml
services:
  joomla:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: joomla6-app
    ports:
      - "${APP_PORT}:80"
    volumes:
      - ./src:/var/www/html
      - ./docker/apache/000-default.conf:/etc/apache2/sites-available/000-default.conf:ro
    depends_on:
      mysql:
        condition: service_healthy
    restart: unless-stopped

  mysql:
    image: mysql:8.4
    container_name: joomla6-db
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    ports:
      - "${MYSQL_PORT}:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./mysql/init:/docker-entrypoint-initdb.d:ro
    command:
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -uroot -p${MYSQL_ROOT_PASSWORD} || exit 1"]
      interval: 5s
      timeout: 5s
      retries: 20
      start_period: 30s
    restart: unless-stopped

  phpmyadmin:
    image: phpmyadmin:latest
    container_name: joomla6-phpmyadmin
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
    ports:
      - "${PMA_PORT}:80"
    depends_on:
      mysql:
        condition: service_healthy
    restart: unless-stopped

volumes:
  mysql_data:
```

Do not add this option when using MySQL 8.4:

```yaml
--default-authentication-plugin=mysql_native_password
```

### 3.7 Create `.gitignore`

```gitignore
/src/*
!/src/.gitkeep
.env
.DS_Store
.idea/
.vscode/
```

---

## 4. Download and Add Joomla

Download the latest Joomla Full Package:

https://downloads.joomla.org/latest?utm_source=chatgpt.com

Choose **Full Package**, not **Upgrade Package**.

Extract all Joomla files directly into:

```text
joomla6-wrapper/src/
```

Correct structure:

```text
src/
├── administrator/
├── api/
├── components/
├── installation/
├── libraries/
├── plugins/
├── templates/
├── index.php
└── htaccess.txt
```

Incorrect structure:

```text
src/Joomla_6.x.x-Stable-Full_Package/index.php
```

Correct structure:

```text
src/index.php
```

Verify the source:

```bash
ls src/index.php
ls src/installation
```

---

## 5. Understand the Installation Folder

The `src/installation/` folder contains the Joomla web installer.

It is responsible for:

- displaying the installation screens;
- creating the Administrator account;
- checking PHP and database connectivity;
- creating Joomla database tables;
- generating `configuration.php`.

Before installation:

```text
installation/       exists
configuration.php   does not exist
```

After installation:

```text
configuration.php   exists
installation/       is removed or no longer used
```

Do not delete `installation/` before the setup is complete.

Do not create an empty `configuration.php` file manually.

---

## 6. Start the Project

Build and start the containers:

```bash
docker compose up -d --build
```

Check their status:

```bash
docker compose ps
```

Expected result:

```text
joomla6-app            running
joomla6-db             running (healthy)
joomla6-phpmyadmin     running
```

Useful log commands:

```bash
docker compose logs -f joomla
docker compose logs -f mysql
```

Verify the Joomla source inside the container:

```bash
docker compose exec joomla ls -la /var/www/html
```

---

## 7. Complete the Joomla Installer

Open:

```text
http://localhost:8080
```

### Step 1: Site Configuration

Example:

```text
Site Name: Joomla 6 Local
```

### Step 2: Administrator Account

Example:

```text
Real Name: Local Administrator
Username: admin
Password: use a strong password
Email: admin@example.com
```

This account is for Joomla Administrator. It is not the MySQL account.

### Step 3: Database Configuration

Use these values:

| Field | Value |
|---|---|
| Database Type | `MySQLi` |
| Host Name | `mysql` |
| Username | `joomla` |
| Password | `joomla_password` |
| Database Name | `joomla6` |
| Table Prefix | Keep the generated value |
| Connection Encryption | Default |

The database host must be `mysql` because that is the Docker Compose service name.

Do not use:

```text
localhost
localhost:3307
host.docker.internal
```

`3307` is the host-machine port. Joomla connects to MySQL inside Docker through:

```text
mysql:3306
```

### Database host verification

Joomla may treat `mysql` as a remote database host and ask you to verify ownership.

Follow the exact instruction shown by the installer. It normally asks you to create or remove a randomly named file inside:

```text
src/installation/
```

Example:

```bash
touch src/installation/<exact-file-name-from-joomla>
```

Use the exact filename displayed by Joomla.

---

## 8. How configuration.php Is Created

After you click **Install Joomla**, Joomla will:

1. connect to MySQL;
2. create the Joomla tables;
3. create the Administrator account;
4. save the site settings;
5. generate `src/configuration.php`.

Important database settings inside the generated file look similar to this:

```php
public $dbtype = 'mysqli';
public $host = 'mysql';
public $user = 'joomla';
public $password = 'joomla_password';
public $db = 'joomla6';
public $dbprefix = 'abc12_';
```

The prefix is added to Joomla table names, for example:

```text
abc12_users
abc12_content
abc12_extensions
```

Do not change `dbprefix` after installation unless you also rename every related database table.

---

## 9. Fix configuration.php Write Errors

Test whether Apache can write to the Joomla folder:

```bash
docker compose exec -u www-data joomla touch /var/www/html/test-write.txt
```

If the command fails, update the local permissions:

```bash
docker compose exec joomla chown -R www-data:www-data /var/www/html
```

Remove the test file:

```bash
docker compose exec joomla rm -f /var/www/html/test-write.txt
```

If Joomla displays the configuration content instead of creating the file:

1. Create `src/configuration.php`.
2. Paste the complete content generated by Joomla.
3. Validate the PHP syntax:

```bash
docker compose exec joomla php -l /var/www/html/configuration.php
```

Expected output:

```text
No syntax errors detected in /var/www/html/configuration.php
```

Do not write the configuration file from scratch unless necessary.

---

## 10. Access the Website

Frontend:

```text
http://localhost:8080
```

Administrator:

```text
http://localhost:8080/administrator
```

phpMyAdmin:

```text
http://localhost:8081
```

After installation, verify that the file exists:

```bash
ls -la src/configuration.php
```

---

## 11. Reset the Installation

To remove the database and start again:

```bash
docker compose down -v
rm -f src/configuration.php
```

Make sure `src/installation/` still exists. If it was removed, extract it again from the Joomla Full Package.

Start the project again:

```bash
docker compose up -d --build
```

Warning: `docker compose down -v` permanently removes the Docker database volume.

---

## 12. Final Checklist

- [ ] Docker Desktop is running.
- [ ] Joomla Full Package was downloaded.
- [ ] `src/index.php` exists.
- [ ] `src/installation/` exists before installation.
- [ ] MySQL container is healthy.
- [ ] Joomla opens at `http://localhost:8080`.
- [ ] Database host is `mysql`.
- [ ] Database credentials match `.env`.
- [ ] Joomla creates its database tables.
- [ ] `src/configuration.php` is generated.
- [ ] Frontend and Administrator pages are accessible.
