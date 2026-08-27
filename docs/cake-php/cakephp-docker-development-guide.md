# CakePHP Docker Development Guide

> A practical Docker development setup for CakePHP using Apache, PHP, MySQL, a custom VirtualHost, and a host-mounted `www/` directory as the application workspace.

> **Target stack:** CakePHP 5.x, PHP 8.4 + Apache, MySQL 8.4, Docker Compose.

## Table of Contents

- [1. Goal](#1-goal)
- [2. Architecture](#2-architecture)
- [3. Final Project Structure](#3-final-project-structure)
- [4. Request and Database Flow](#4-request-and-database-flow)
- [5. Prerequisites](#5-prerequisites)
- [6. Environment Configuration](#6-environment-configuration)
- [7. PHP Dockerfile](#7-php-dockerfile)
- [8. PHP Configuration](#8-php-configuration)
- [9. Apache VirtualHost](#9-apache-virtualhost)
- [10. MySQL Configuration](#10-mysql-configuration)
- [11. Docker Compose](#11-docker-compose)
- [12. Docker Ignore File](#12-docker-ignore-file)
- [13. Create a New CakePHP Project in www](#13-create-a-new-cakephp-project-in-www)
- [14. Run an Existing CakePHP Project in www](#14-run-an-existing-cakephp-project-in-www)
- [15. Configure CakePHP Database Connection](#15-configure-cakephp-database-connection)
- [16. Configure the Local Hostname](#16-configure-the-local-hostname)
- [17. Start the Environment](#17-start-the-environment)
- [18. Verify the Environment](#18-verify-the-environment)
- [19. Daily Development Commands](#19-daily-development-commands)
- [20. Database Commands](#20-database-commands)
- [21. CakePHP Commands](#21-cakephp-commands)
- [22. Logs and Debugging](#22-logs-and-debugging)
- [23. Common Problems](#23-common-problems)
- [24. Resetting the Environment](#24-resetting-the-environment)
- [25. Development vs Production](#25-development-vs-production)
- [26. Setup Checklist](#26-setup-checklist)
- [27. Configuration Map](#27-configuration-map)
- [28. Related Documentation](#28-related-documentation)
- [29. References](#29-references)

---

## 1. Goal

The goal is to run a CakePHP application with the following separation:

```text
Host Machine
│
├── Docker configuration
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── php.ini
│   ├── Apache VirtualHost
│   └── MySQL configuration
│
└── www/
    └── CakePHP project
```

The important rule is:

> **`www/` is the location where the CakePHP project is stored and edited on the host machine.**

Inside the PHP container, the same directory is mounted as:

```text
/var/www/html
```

Apache serves only CakePHP's public directory:

```text
/var/www/html/webroot
```

This prevents Apache from exposing application directories such as:

```text
config/
src/
templates/
vendor/
tests/
logs/
```

---

## 2. Architecture

The development environment contains two main containers:

```text
+-------------------------+
|      Host Machine       |
|                         |
|  www/                   |
|  docker/                |
|  docker-compose.yml     |
+------------+------------+
             |
             | Bind mount
             v
+-------------------------+
| app                     |
| PHP 8.4 + Apache        |
|                         |
| /var/www/html           |
|        |                |
|        +-- webroot/     |
+------------+------------+
             |
             | Docker network
             |
             v
+-------------------------+
| mysql                   |
| MySQL 8.4               |
|                         |
| cakephp database        |
+-------------------------+
```

The browser accesses Apache.

CakePHP accesses MySQL through Docker's internal network.

---

## 3. Final Project Structure

Create the Docker workspace with this structure:

```text
cakephp-docker/
├── .dockerignore
├── .env
├── .env.example
├── docker-compose.yml
│
├── docker/
│   ├── apache/
│   │   └── vhost.conf
│   │
│   ├── mysql/
│   │   └── my.cnf
│   │
│   └── php/
│       ├── Dockerfile
│       └── php.ini
│
└── www/
    ├── bin/
    ├── config/
    ├── logs/
    ├── plugins/
    ├── resources/
    ├── src/
    ├── templates/
    ├── tests/
    ├── tmp/
    ├── vendor/
    ├── webroot/
    ├── composer.json
    └── ...
```

Before CakePHP is installed, `www/` can be empty:

```text
cakephp-docker/
├── docker/
├── docker-compose.yml
└── www/
```

After Composer creates the application, `www/` becomes the CakePHP project root.

### Responsibility map

| Path | Responsibility |
|---|---|
| `docker-compose.yml` | Defines and connects the containers |
| `docker/php/Dockerfile` | Builds PHP + Apache and PHP extensions |
| `docker/php/php.ini` | PHP runtime configuration |
| `docker/apache/vhost.conf` | Apache document root and VirtualHost |
| `docker/mysql/my.cnf` | MySQL server configuration |
| `.env` | Local Docker environment values |
| `www/` | CakePHP application source |
| `www/webroot/` | Public CakePHP web root |
| Docker volume `mysql_data` | Persistent MySQL data |

---

## 4. Request and Database Flow

### HTTP request flow

```mermaid
flowchart LR
    A["Browser"] --> B["cakephp.local:8080"]
    B --> C["Docker port 8080 to 80"]
    C --> D["Apache VirtualHost"]
    D --> E["/var/www/html/webroot"]
    E --> F["index.php"]
    F --> G["CakePHP"]
```

### Database flow

```mermaid
flowchart LR
    A["CakePHP"] --> B["DB_HOST=mysql"]
    B --> C["Docker network"]
    C --> D["MySQL container"]
    D --> E["cakephp database"]
```

A critical Docker rule:

```text
CakePHP container -> MySQL container

Correct host:
mysql

Incorrect host:
localhost
127.0.0.1
```

Inside the `app` container, `localhost` means the PHP container itself, not the MySQL container.

---

## 5. Prerequisites

Install:

- Docker Desktop, Docker Engine, or another Docker-compatible runtime;
- Docker Compose v2;
- Git if you want to clone an existing project.

Verify:

```bash
docker --version
docker compose version
```

For CakePHP 5.x, the important PHP requirements include:

```text
PHP 8.2+
mbstring
intl
PDO
SimpleXML
```

When MySQL is used, PHP also needs:

```text
pdo_mysql
```

This guide uses:

```text
PHP 8.4
Apache
MySQL 8.4
Composer 2
```

---

## 6. Environment Configuration

Create:

```text
.env.example
```

with:

```dotenv
APP_PORT=8080
MYSQL_HOST_PORT=3307

MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE=cakephp
MYSQL_USER=cakephp
MYSQL_PASSWORD=cakephp_password

DEBUG=true
```

Copy it to:

```text
.env
```

Linux/macOS:

```bash
cp .env.example .env
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

### Development example

```dotenv
APP_PORT=8080
MYSQL_HOST_PORT=3307

MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=cakephp
MYSQL_USER=cakephp
MYSQL_PASSWORD=cakephp

DEBUG=true
```

### Important

The values above are suitable only as simple local development examples.

Do not use weak passwords in production.

Add `.env` to Git ignore rules:

```gitignore
.env
```

Commit `.env.example`, not real secrets.

---

## 7. PHP Dockerfile

Create:

```text
docker/php/Dockerfile
```

with:

```dockerfile
FROM php:8.4-apache

# Install operating-system libraries required by PHP extensions
# and common CakePHP development tools.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libicu-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
    && docker-php-ext-install -j"$(nproc)" \
        intl \
        mbstring \
        pdo_mysql \
        simplexml \
        zip \
    && rm -rf /var/lib/apt/lists/*

# CakePHP commonly uses URL rewriting.
RUN a2enmod rewrite

# Install Composer from the official Composer image.
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Apache VirtualHost configuration.
COPY docker/apache/vhost.conf /etc/apache2/sites-available/000-default.conf

# Development PHP configuration.
COPY docker/php/php.ini /usr/local/etc/php/conf.d/99-cakephp.ini

WORKDIR /var/www/html

EXPOSE 80
```

### What this Dockerfile does

```text
php:8.4-apache
    |
    +-- Apache
    +-- PHP 8.4
    |
    +-- intl
    +-- mbstring
    +-- pdo_mysql
    +-- simplexml
    +-- zip
    |
    +-- mod_rewrite
    |
    +-- Composer
    |
    +-- CakePHP Apache vhost
    +-- CakePHP php.ini
```

### Why these extensions are installed

| Extension | Purpose |
|---|---|
| `intl` | Internationalization and locale support required by CakePHP |
| `mbstring` | Multibyte string support required by CakePHP |
| `pdo_mysql` | MySQL database connectivity |
| `simplexml` | XML support required by CakePHP |
| `zip` | Useful for Composer/packages and application ZIP handling |

---

## 8. PHP Configuration

The user-facing term is often written as "PHP init", but the actual PHP configuration file is:

```text
php.ini
```

Create:

```text
docker/php/php.ini
```

with:

```ini
; ------------------------------------------------------------
; CakePHP local development PHP settings
; ------------------------------------------------------------

date.timezone = Asia/Ho_Chi_Minh

display_errors = On
display_startup_errors = On
error_reporting = E_ALL

memory_limit = 512M

upload_max_filesize = 32M
post_max_size = 32M

max_execution_time = 120
max_input_time = 120

variables_order = EGPCS

; Development-friendly OPcache behavior.
; Enable and tune this differently for production.
opcache.enable = 0
```

### Why keep this separate?

Do not put PHP runtime configuration directly into the Dockerfile unless necessary.

Keeping:

```text
Dockerfile
php.ini
```

separate makes it easier to change PHP settings without making the Dockerfile difficult to read.

### Check loaded PHP configuration

After the container is running:

```bash
docker compose exec app php --ini
```

Check a value:

```bash
docker compose exec app php -i | grep memory_limit
```

---

## 9. Apache VirtualHost

Create:

```text
docker/apache/vhost.conf
```

with:

```apache
<VirtualHost *:80>
    ServerName cakephp.local

    DocumentRoot /var/www/html/webroot

    <Directory /var/www/html/webroot>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

### Important configuration

The most important line is:

```apache
DocumentRoot /var/www/html/webroot
```

Do **not** use:

```apache
DocumentRoot /var/www/html
```

for a normal CakePHP deployment.

CakePHP expects the public web directory to be:

```text
webroot/
```

### Why `AllowOverride All`?

CakePHP's Apache setup can use `.htaccess` rewrite rules.

Therefore:

```apache
AllowOverride All
```

allows CakePHP's rewrite configuration to work.

The Dockerfile also enables:

```bash
a2enmod rewrite
```

### Verify Apache modules

```bash
docker compose exec app apache2ctl -M
```

Look for:

```text
rewrite_module
```

### Verify the active VirtualHost

```bash
docker compose exec app apache2ctl -S
```

---

## 10. MySQL Configuration

Create:

```text
docker/mysql/my.cnf
```

with:

```ini
[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_0900_ai_ci

[client]
default-character-set = utf8mb4
```

This gives the development database a predictable UTF-8 configuration.

### Why `utf8mb4`?

`utf8mb4` supports the full Unicode range.

It is normally preferable to old MySQL `utf8` configurations for modern applications.

### MySQL data storage

Do not store MySQL data inside `www/`.

Docker Compose will use a named volume:

```text
mysql_data
```

Conceptually:

```text
www/
    -> CakePHP source

mysql_data
    -> MySQL database files
```

They are separate responsibilities.

---

## 11. Docker Compose

Create:

```text
docker-compose.yml
```

with:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: docker/php/Dockerfile

    container_name: cakephp_app

    ports:
      - "${APP_PORT:-8080}:80"

    volumes:
      - ./www:/var/www/html

    environment:
      DEBUG: "${DEBUG:-true}"

      DB_HOST: mysql
      DB_PORT: 3306
      DB_DATABASE: "${MYSQL_DATABASE}"
      DB_USERNAME: "${MYSQL_USER}"
      DB_PASSWORD: "${MYSQL_PASSWORD}"

    depends_on:
      mysql:
        condition: service_healthy

    networks:
      - cakephp_network

  mysql:
    image: mysql:8.4

    container_name: cakephp_mysql

    ports:
      - "${MYSQL_HOST_PORT:-3307}:3306"

    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
      MYSQL_DATABASE: "${MYSQL_DATABASE}"
      MYSQL_USER: "${MYSQL_USER}"
      MYSQL_PASSWORD: "${MYSQL_PASSWORD}"

    volumes:
      - mysql_data:/var/lib/mysql
      - ./docker/mysql/my.cnf:/etc/mysql/conf.d/cakephp.cnf:ro

    healthcheck:
      test:
        [
          "CMD-SHELL",
          "mysqladmin ping -h 127.0.0.1 -u root -p$$MYSQL_ROOT_PASSWORD --silent"
        ]
      interval: 5s
      timeout: 5s
      retries: 20
      start_period: 20s

    networks:
      - cakephp_network

volumes:
  mysql_data:

networks:
  cakephp_network:
    driver: bridge
```

### Service map

```text
app
├── PHP 8.4
├── Apache
├── Composer
├── ./www -> /var/www/html
└── Port 8080 -> 80

mysql
├── MySQL 8.4
├── mysql_data -> /var/lib/mysql
└── Port 3307 -> 3306
```

### Port meanings

#### Web

Host:

```text
localhost:8080
```

Container:

```text
app:80
```

#### MySQL

Host:

```text
localhost:3307
```

Container:

```text
mysql:3306
```

CakePHP must use the **container-side** connection:

```text
host=mysql
port=3306
```

A desktop database client running on the host can use:

```text
host=127.0.0.1
port=3307
```

---

## 12. Docker Ignore File

Create:

```text
.dockerignore
```

with:

```dockerignore
.git
.gitignore

.env

www/vendor
www/logs
www/tmp

README.md
```

For this development architecture, `www/` is bind-mounted at runtime rather than copied into the image.

The ignore file mainly helps keep the Docker build context clean.

Do not blindly reuse this `.dockerignore` for a production image that needs to copy application source into the image.

---

## 13. Create a New CakePHP Project in www

Start with an empty directory:

```text
www/
```

### Step 1 — Build the PHP image

```bash
docker compose build app
```

### Step 2 — Create CakePHP inside `www/`

Run:

```bash
docker compose run --rm --no-deps app \
  composer create-project --prefer-dist cakephp/app:~5.4 .
```

Because:

```text
./www
    |
    | bind mounted
    v
/var/www/html
```

Composer creates CakePHP directly inside the host's `www/` directory.

After installation:

```text
www/
├── bin/
├── config/
├── logs/
├── plugins/
├── resources/
├── src/
├── templates/
├── tests/
├── tmp/
├── vendor/
├── webroot/
├── composer.json
└── ...
```

### Verify CakePHP files

```bash
docker compose run --rm --no-deps app ls -la
```

---

## 14. Run an Existing CakePHP Project in www

If the CakePHP project already exists, place or clone it into:

```text
www/
```

Example:

```bash
git clone <repository-url> www
```

The result should be:

```text
www/composer.json
www/bin/
www/config/
www/src/
www/webroot/
```

Not:

```text
www/project-name/composer.json
```

unless you intentionally change the Docker mount path.

### Install dependencies

Build the image:

```bash
docker compose build app
```

Then:

```bash
docker compose run --rm --no-deps app composer install
```

### Existing application configuration

Before starting, inspect:

```text
www/config/app.php
www/config/app_local.php
www/config/.env
www/.env
```

The exact environment strategy depends on the existing project.

Do not overwrite production credentials or project-specific configuration without reviewing it first.

---

## 15. Configure CakePHP Database Connection

The Docker Compose service passes these values into the PHP container:

```text
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=<MYSQL_DATABASE>
DB_USERNAME=<MYSQL_USER>
DB_PASSWORD=<MYSQL_PASSWORD>
```

Configure CakePHP to read them.

Open:

```text
www/config/app_local.php
```

Locate:

```php
'Datasources' => [
    'default' => [
        // ...
    ],
],
```

A development configuration can look like:

```php
'Datasources' => [
    'default' => [
        'className' => 'Cake\\Database\\Connection',
        'driver' => 'Cake\\Database\\Driver\\Mysql',
        'persistent' => false,

        'host' => env('DB_HOST', 'mysql'),
        'port' => (int)env('DB_PORT', 3306),

        'username' => env('DB_USERNAME', 'cakephp'),
        'password' => env('DB_PASSWORD', 'cakephp'),
        'database' => env('DB_DATABASE', 'cakephp'),

        'encoding' => 'utf8mb4',
        'timezone' => 'UTC',
        'cacheMetadata' => true,
    ],
],
```

If the existing project already has additional datasource settings, preserve them unless there is a clear reason to change them.

### Most common Docker database mistake

Wrong:

```php
'host' => 'localhost',
```

Wrong:

```php
'host' => '127.0.0.1',
```

Correct:

```php
'host' => 'mysql',
```

because `mysql` is the Docker Compose service name.

---

## 16. Configure the Local Hostname

The Apache VirtualHost uses:

```text
cakephp.local
```

Add it to the host machine's hosts file.

### Windows

Open as Administrator:

```text
C:\Windows\System32\drivers\etc\hosts
```

Add:

```text
127.0.0.1 cakephp.local
```

### macOS / Linux

Edit:

```text
/etc/hosts
```

Add:

```text
127.0.0.1 cakephp.local
```

### URL

With:

```dotenv
APP_PORT=8080
```

open:

```text
http://cakephp.local:8080
```

You can also access:

```text
http://localhost:8080
```

but using `cakephp.local` verifies that the local hostname/VHost setup is working as intended.

---

## 17. Start the Environment

### Build

```bash
docker compose build
```

### Start

```bash
docker compose up -d
```

### Check containers

```bash
docker compose ps
```

Expected services:

```text
cakephp_app
cakephp_mysql
```

The MySQL service should eventually report a healthy state.

### Browser

Open:

```text
http://cakephp.local:8080
```

For a fresh CakePHP installation, the CakePHP home page should load.

---

## 18. Verify the Environment

Do not stop after seeing that the containers are running.

Verify each layer.

### 18.1 PHP version

```bash
docker compose exec app php -v
```

Expected:

```text
PHP 8.4.x
```

### 18.2 Required PHP extensions

```bash
docker compose exec app php -m
```

Confirm at least:

```text
intl
mbstring
PDO
pdo_mysql
SimpleXML
```

A compact Linux-container check:

```bash
docker compose exec app sh -lc \
  "php -m | grep -Ei 'intl|mbstring|PDO|pdo_mysql|SimpleXML'"
```

### 18.3 Composer

```bash
docker compose exec app composer --version
```

### 18.4 CakePHP

```bash
docker compose exec app php bin/cake version
```

Or:

```bash
docker compose exec app composer show cakephp/cakephp
```

### 18.5 Apache VirtualHost

```bash
docker compose exec app apache2ctl -S
```

Verify the document root configuration points to:

```text
/var/www/html/webroot
```

### 18.6 Apache rewrite module

```bash
docker compose exec app apache2ctl -M | grep rewrite
```

Expected:

```text
rewrite_module
```

### 18.7 MySQL health

```bash
docker compose ps
```

Or:

```bash
docker compose exec mysql \
  sh -lc 'mysqladmin ping -h 127.0.0.1 -u root -p"$MYSQL_ROOT_PASSWORD"'
```

Expected:

```text
mysqld is alive
```

### 18.8 Database login

```bash
docker compose exec mysql sh -lc \
  'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'
```

Inside MySQL:

```sql
SHOW DATABASES;
SHOW TABLES;
```

Exit:

```sql
exit
```

---

## 19. Daily Development Commands

### Start

```bash
docker compose up -d
```

### Stop containers

```bash
docker compose stop
```

### Start stopped containers

```bash
docker compose start
```

### Stop and remove containers

```bash
docker compose down
```

This does **not** remove the named MySQL volume by default.

### Rebuild after Dockerfile changes

```bash
docker compose build app
docker compose up -d
```

Or:

```bash
docker compose up -d --build
```

### Open a shell in PHP container

```bash
docker compose exec app bash
```

### Open a shell in MySQL container

```bash
docker compose exec mysql bash
```

---

## 20. Database Commands

### Connect from inside Docker

```bash
docker compose exec mysql sh -lc \
  'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'
```

### Connect from the host machine

Using the example configuration:

```text
Host:     127.0.0.1
Port:     3307
Database: cakephp
Username: cakephp
Password: cakephp
```

This is useful for:

- MySQL Workbench;
- DBeaver;
- DataGrip;
- TablePlus;
- IDE database clients.

### Important distinction

From CakePHP container:

```text
mysql:3306
```

From host machine:

```text
127.0.0.1:3307
```

These are not interchangeable.

---

## 21. CakePHP Commands

Run CakePHP CLI commands inside the app container.

### Version

```bash
docker compose exec app php bin/cake version
```

### Show routes

```bash
docker compose exec app php bin/cake routes
```

### Clear cache

```bash
docker compose exec app php bin/cake cache clear_all
```

### Bake

If Bake is installed:

```bash
docker compose exec app php bin/cake bake
```

Example:

```bash
docker compose exec app php bin/cake bake model Users
```

### Database migrations

If the project uses CakePHP Migrations:

```bash
docker compose exec app php bin/cake migrations status
```

Run migrations:

```bash
docker compose exec app php bin/cake migrations migrate
```

Always review production migrations before execution.

---

## 22. Logs and Debugging

### All Docker logs

```bash
docker compose logs
```

### Follow logs

```bash
docker compose logs -f
```

### PHP/Apache logs

```bash
docker compose logs -f app
```

### MySQL logs

```bash
docker compose logs -f mysql
```

### CakePHP logs

Because `www/` is bind-mounted:

```text
www/logs/
```

is directly available on the host machine.

Typical files can include:

```text
www/logs/error.log
www/logs/debug.log
```

The exact filenames depend on the CakePHP logging configuration.

### Check CakePHP debug mode

Docker Compose passes:

```text
DEBUG=true
```

The CakePHP configuration must actually read the `DEBUG` environment variable for this value to affect the application.

Do not assume Docker environment values automatically override every CakePHP configuration value.

---

## 23. Common Problems

### Problem 1 — CakePHP cannot connect to MySQL

Example:

```text
Connection to Mysql could not be established
```

Check:

```bash
docker compose ps
docker compose logs mysql
```

Then verify:

```text
DB_HOST=mysql
DB_PORT=3306
```

Do not use:

```text
localhost
127.0.0.1
```

inside the CakePHP container.

---

### Problem 2 — Access denied for MySQL user

Example:

```text
SQLSTATE[HY000] [1045] Access denied
```

Check:

- `MYSQL_USER`;
- `MYSQL_PASSWORD`;
- CakePHP `DB_USERNAME`;
- CakePHP `DB_PASSWORD`;
- whether the MySQL volume was initialized with older credentials.

A MySQL Docker volume is initialized only when the database directory is empty.

Changing `.env` does not automatically recreate existing MySQL users in an already initialized volume.

---

### Problem 3 — Database name does not exist

Example:

```text
Unknown database
```

Verify:

```dotenv
MYSQL_DATABASE=cakephp
```

Then:

```bash
docker compose exec mysql sh -lc \
  'mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;"'
```

---

### Problem 4 — CakePHP routes return 404

Check Apache rewrite:

```bash
docker compose exec app apache2ctl -M | grep rewrite
```

Check vhost:

```bash
docker compose exec app apache2ctl -S
```

Check:

```apache
AllowOverride All
```

Check that CakePHP's `.htaccess` files have not been removed if the application expects them.

---

### Problem 5 — Apache shows the wrong directory

Verify:

```apache
DocumentRoot /var/www/html/webroot
```

Do not serve:

```text
/var/www/html
```

directly.

---

### Problem 6 — `cakephp.local` does not resolve

Check the host operating system's hosts file:

```text
127.0.0.1 cakephp.local
```

Then verify:

```text
http://cakephp.local:8080
```

If Apache works on:

```text
http://localhost:8080
```

but not on `cakephp.local`, the problem is likely host-name resolution rather than CakePHP.

---

### Problem 7 — Port already in use

Example:

```text
Bind for 0.0.0.0:8080 failed: port is already allocated
```

Change:

```dotenv
APP_PORT=8081
```

Then restart:

```bash
docker compose down
docker compose up -d
```

Open:

```text
http://cakephp.local:8081
```

---

### Problem 8 — MySQL host port already in use

Change:

```dotenv
MYSQL_HOST_PORT=3308
```

CakePHP still uses:

```text
mysql:3306
```

because only the host-side port changed.

---

### Problem 9 — CakePHP cannot write to tmp or logs

CakePHP needs writable runtime directories.

Check:

```text
www/tmp/
www/logs/
```

From the container:

```bash
docker compose exec app ls -ld tmp logs
```

For local Linux environments, filesystem ownership can differ between the host user and the container's `www-data` user.

Fix permissions deliberately for your local environment rather than applying recursive `777` permissions to the entire project.

Do not make application source globally writable as a generic fix.

---

### Problem 10 — Composer dependencies are missing

Run:

```bash
docker compose exec app composer install
```

Or before containers are started:

```bash
docker compose run --rm --no-deps app composer install
```

Verify:

```text
www/vendor/
```

exists.

---

## 24. Resetting the Environment

### Safe container reset

This removes containers and the Docker network but keeps MySQL data:

```bash
docker compose down
docker compose up -d
```

### Rebuild PHP image

```bash
docker compose down
docker compose build --no-cache app
docker compose up -d
```

### Full database reset

> **Warning: this deletes the Docker MySQL volume and all data stored in it.**

Only run this when losing the local database is acceptable:

```bash
docker compose down -v
docker compose up -d
```

This is useful when you intentionally want MySQL to initialize again from new environment values.

Do not use it as a casual troubleshooting command if the database contains important data.

---

## 25. Development vs Production

This guide is intentionally optimized for **local development**.

### Development

```text
Host source:
www/

Bind mount:
./www:/var/www/html

PHP errors:
visible

MySQL host port:
exposed for DB tools

Source changes:
immediately available
```

### Production

A production setup should normally differ.

Consider:

- copy application source into an immutable image;
- run `composer install --no-dev --optimize-autoloader`;
- disable `display_errors`;
- enable and tune OPcache;
- use real secret management;
- do not expose MySQL publicly unless required;
- use TLS/HTTPS;
- use a reverse proxy or production web-server architecture where appropriate;
- configure backups;
- configure logging and monitoring;
- use supported CakePHP/PHP/MySQL releases;
- apply least-privilege database credentials;
- perform migration and rollback planning.

Do not deploy the local-development `.env` passwords to production.

---

## 26. Setup Checklist

### Files

- [ ] Create `.env.example`.
- [ ] Create local `.env`.
- [ ] Create `.dockerignore`.
- [ ] Create `docker-compose.yml`.
- [ ] Create `docker/php/Dockerfile`.
- [ ] Create `docker/php/php.ini`.
- [ ] Create `docker/apache/vhost.conf`.
- [ ] Create `docker/mysql/my.cnf`.
- [ ] Create `www/`.

### PHP

- [ ] PHP 8.4 container builds successfully.
- [ ] `intl` is installed.
- [ ] `mbstring` is installed.
- [ ] `PDO` is available.
- [ ] `pdo_mysql` is installed.
- [ ] `SimpleXML` is available.
- [ ] Composer is installed.

### Apache

- [ ] `mod_rewrite` is enabled.
- [ ] ServerName is `cakephp.local`.
- [ ] DocumentRoot is `/var/www/html/webroot`.
- [ ] `AllowOverride All` is enabled for CakePHP webroot.

### MySQL

- [ ] MySQL container starts.
- [ ] MySQL healthcheck passes.
- [ ] Database exists.
- [ ] Application user exists.
- [ ] Host client can connect through port `3307` if needed.

### CakePHP

- [ ] CakePHP source exists directly under `www/`.
- [ ] Composer dependencies are installed.
- [ ] Database host is `mysql`.
- [ ] Database port is `3306`.
- [ ] `tmp/` is writable.
- [ ] `logs/` is writable.
- [ ] CakePHP home page loads.
- [ ] Database connection succeeds.

### Host

- [ ] Hosts file contains `127.0.0.1 cakephp.local`.
- [ ] `http://cakephp.local:8080` resolves.
- [ ] Host ports do not conflict with existing services.

---

## 27. Configuration Map

Use this map when debugging which file controls which behavior.

```text
cakephp-docker/
│
├── .env
│   ├── APP_PORT
│   ├── MYSQL_HOST_PORT
│   ├── MYSQL_DATABASE
│   ├── MYSQL_USER
│   └── MYSQL_PASSWORD
│
├── docker-compose.yml
│   ├── creates app container
│   ├── creates mysql container
│   ├── mounts www/
│   ├── creates Docker network
│   ├── creates mysql_data
│   └── passes DB_* variables to CakePHP
│
├── docker/
│   │
│   ├── php/
│   │   ├── Dockerfile
│   │   │   ├── PHP 8.4
│   │   │   ├── Apache
│   │   │   ├── PHP extensions
│   │   │   ├── Composer
│   │   │   └── mod_rewrite
│   │   │
│   │   └── php.ini
│   │       ├── timezone
│   │       ├── memory
│   │       ├── upload limits
│   │       └── error display
│   │
│   ├── apache/
│   │   └── vhost.conf
│   │       ├── cakephp.local
│   │       └── /var/www/html/webroot
│   │
│   └── mysql/
│       └── my.cnf
│           └── utf8mb4
│
└── www/
    ├── config/
    │   └── app_local.php
    │       └── CakePHP database connection
    │
    ├── src/
    │   └── application code
    │
    ├── templates/
    │   └── views
    │
    ├── webroot/
    │   └── Apache public document root
    │
    ├── tmp/
    │   └── writable CakePHP runtime data
    │
    └── logs/
        └── CakePHP application logs
```

### End-to-end configuration chain

```text
.env
  |
  v
docker-compose.yml
  |
  +--------------------+
  |                    |
  v                    v
app container       mysql container
  |                    |
  | DB_HOST=mysql      |
  |                    |
  v                    |
CakePHP                 |
config/app_local.php    |
  |                     |
  +---------------------+
            |
            v
       MySQL database
```

---

## 28. Related Documentation

Continue with:

- [**What Is CakePHP?**](./what-is-cakephp.md)
- [**CakePHP Project Structure Guide**](./cakephp-project-structure.md)

Recommended reading order:

```text
1. What Is CakePHP?
        |
        v
2. CakePHP Project Structure
        |
        v
3. CakePHP Docker Development Guide
        |
        v
4. Build and inspect a real CakePHP project
```

---

## 29. References

Official references used to verify the technical baseline of this guide:

- [CakePHP 5.x Installation Guide](https://book.cakephp.org/5.x/installation.html)
- [CakePHP 5.x Documentation](https://book.cakephp.org/5.x/)
- [CakePHP 5.x Quick Start Guide](https://book.cakephp.org/5.x/quickstart.html)
- [Docker Official PHP Image](https://hub.docker.com/_/php)
- [Docker Official PHP Image Source](https://github.com/docker-library/php)
- [Docker Official MySQL Image](https://hub.docker.com/_/mysql)

---

## Summary

The recommended local structure is:

```text
cakephp-docker/
├── docker-compose.yml
├── .env
├── docker/
│   ├── apache/vhost.conf
│   ├── mysql/my.cnf
│   └── php/
│       ├── Dockerfile
│       └── php.ini
└── www/
    └── CakePHP application
```

The key runtime mappings are:

```text
Host CakePHP source:
./www

PHP container:
./www -> /var/www/html

Apache public root:
/var/www/html/webroot

CakePHP -> MySQL:
mysql:3306

Host -> MySQL:
127.0.0.1:3307

Browser:
http://cakephp.local:8080
```

For local development, keep Docker infrastructure outside `www/` and keep the CakePHP application itself entirely inside `www/`.
