# Joomla 6 Local Setup with Docker

A beginner-friendly guide to create a reusable Docker wrapper, add the Joomla source code, run the installer, and generate `configuration.php`.

## Table of Contents

- [1. Setup Flow](#1-setup-flow)
- [2. Project Structure](#2-project-structure)
- [3. Create the Docker Wrapper](#3-create-the-docker-wrapper)
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
→ Configure the website and database
→ Joomla creates its database tables
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

The Docker files form the reusable wrapper. Extract the Joomla source code directly into `src/`.

---

## 3. Create the Docker Wrapper

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
    environment:
      JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK: "1"
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

Do not add this removed MySQL 8.4 option:

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

Do not keep an extra package folder inside `src/`.

Incorrect:

```text
src/Joomla_6.x.x-Stable-Full_Package/index.php
```

Correct:

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

The `src/installation/` folder contains the Joomla web installer. It:

- displays the installation screens;
- creates the Administrator account;
- checks PHP and database connectivity;
- creates Joomla database tables;
- generates `configuration.php`.

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

Do not delete `installation/` before setup is complete, and do not create an empty `configuration.php` manually.

---

## 6. Start the Project

```bash
docker compose up -d --build
docker compose ps
```

Expected services:

```text
joomla6-app            running
joomla6-db             running (healthy)
joomla6-phpmyadmin     running
```

Useful checks:

```bash
docker compose logs -f joomla
docker compose logs -f mysql
docker compose exec joomla ls -la /var/www/html
```

---

## 7. Complete the Joomla Installer

Open:

```text
http://localhost:8080
```

### Step 1: Site Configuration

```text
Site Name: Joomla 6 Local
```

### Step 2: Administrator Account

```text
Real Name: Local Administrator
Username: admin
Password: use a strong password
Email: admin@example.com
```

This is the Joomla Administrator account, not the MySQL account.

### Step 3: Database Configuration

| Field | Value |
|---|---|
| Database Type | `MySQLi` |
| Host Name | `mysql` |
| Username | `joomla` |
| Password | `joomla_password` |
| Database Name | `joomla6` |
| Table Prefix | Keep the generated value |
| Connection Encryption | Default |

> **Docker Host Name note:** Joomla says: “Enter the host name, usually `localhost` or a name provided by your host.” When Joomla and MySQL run in Docker, enter the MySQL **Docker Compose service name** or container hostname instead. In this example, use `mysql`.

The service name comes from:

```yaml
services:
  mysql:
```

Joomla therefore connects internally through:

```text
mysql:3306
```

Do not use `localhost`, `localhost:3307`, or `host.docker.internal` for this wrapper. Port `3307` is only the host-machine port used by external database tools.

### Database host verification warning

Joomla may display:

```text
Warning
You are trying to use a database host which is not on your local server.
For security reasons, you need to verify the ownership of your web hosting account.
```

This happens because Joomla sees `mysql` as a non-local hostname, even though it is a local Docker service.

For a trusted local Docker environment, keep this variable under the `joomla` service:

```yaml
environment:
  JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK: "1"
```

Recreate the container after adding it:

```bash
docker compose down
docker compose up -d --build --force-recreate
```

Verify the variable:

```bash
docker compose exec joomla printenv JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK
```

Expected output:

```text
1
```

Alternatively, follow Joomla's on-screen instruction to create or remove the exact randomly named verification file inside `src/installation/`.

---

## 8. How configuration.php Is Created

After you click **Install Joomla**, Joomla will:

1. connect to MySQL;
2. create the Joomla tables;
3. create the Administrator account;
4. save the site settings;
5. generate `src/configuration.php`.

Important generated values look similar to:

```php
public $dbtype = 'mysqli';
public $host = 'mysql';
public $user = 'joomla';
public $password = 'joomla_password';
public $db = 'joomla6';
public $dbprefix = 'abc12_';
```

The prefix is added to Joomla table names, such as:

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

If it fails:

```bash
docker compose exec joomla chown -R www-data:www-data /var/www/html
```

Remove the test file:

```bash
docker compose exec joomla rm -f /var/www/html/test-write.txt
```

If Joomla displays configuration content instead of creating the file:

1. Create `src/configuration.php`.
2. Paste the complete content generated by Joomla.
3. Validate it:

```bash
docker compose exec joomla php -l /var/www/html/configuration.php
```

Expected output:

```text
No syntax errors detected in /var/www/html/configuration.php
```

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

Verify the generated configuration file:

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

Make sure `src/installation/` exists. If Joomla removed it, extract it again from the Full Package.

```bash
docker compose up -d --build
```

> **Warning:** `docker compose down -v` permanently removes the Docker database volume.

---

## 12. Final Checklist

- [ ] Docker Desktop is running.
- [ ] Joomla Full Package was downloaded.
- [ ] `src/index.php` exists.
- [ ] `src/installation/` exists before installation.
- [ ] MySQL container is healthy.
- [ ] Joomla opens at `http://localhost:8080`.
- [ ] Database host is the Docker service name: `mysql`.
- [ ] Database credentials match `.env`.
- [ ] The database-host warning is disabled locally or manually verified.
- [ ] Joomla creates its database tables.
- [ ] `src/configuration.php` is generated.
- [ ] Frontend and Administrator pages are accessible.
