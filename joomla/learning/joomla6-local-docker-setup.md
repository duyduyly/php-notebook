# Joomla 6 Local Setup với Docker

## Mục tiêu

Tạo một Docker wrapper để chạy Joomla 6 local. Source Joomla được tách riêng trong thư mục `src/` và không cần Composer.

Flow tổng quát:

```text
Tạo Docker wrapper
→ Tải Joomla Full Package
→ Giải nén source vào src/
→ Chạy Docker
→ Mở Joomla Installer
→ Cấu hình website và database
→ Joomla tạo bảng dữ liệu
→ Joomla tạo configuration.php
→ Đăng nhập Administrator
```

---

## 1. Tạo cấu trúc wrapper

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

Tạo thư mục:

```bash
mkdir -p joomla6-wrapper/{docker/apache,docker/php,mysql/init,src}
cd joomla6-wrapper
```

---

## 2. Tạo file `.env`

```env
APP_PORT=8080
PMA_PORT=8081
MYSQL_PORT=3307

MYSQL_DATABASE=joomla6
MYSQL_USER=joomla
MYSQL_PASSWORD=joomla_password
MYSQL_ROOT_PASSWORD=root_password
```

---

## 3. Tạo `Dockerfile`

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

---

## 4. Tạo PHP config

File `docker/php/php.ini`:

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

`display_errors = On` chỉ nên dùng ở local.

---

## 5. Tạo Apache config

File `docker/apache/000-default.conf`:

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

---

## 6. Tạo `docker-compose.yml`

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

Không thêm option sau với MySQL 8.4:

```yaml
--default-authentication-plugin=mysql_native_password
```

---

## 7. Tải và giải nén Joomla

Tải Joomla Full Package tại:

https://downloads.joomla.org/latest?utm_source=chatgpt.com

Chọn bản **Full Package**, không chọn Upgrade Package.

Giải nén toàn bộ source trực tiếp vào `src/`.

Cấu trúc đúng:

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

Không để source bị lồng thêm một cấp thư mục.

Sai:

```text
src/Joomla_6.x.x-Stable-Full_Package/index.php
```

Đúng:

```text
src/index.php
```

---

## 8. Giải thích thư mục `installation`

`src/installation/` là bộ cài đặt ban đầu của Joomla.

Nó thực hiện các việc sau:

- Hiển thị màn hình cài đặt.
- Tạo tài khoản Administrator.
- Kiểm tra PHP và database.
- Tạo các bảng Joomla.
- Tạo file `configuration.php`.

Trước khi cài:

```text
installation/       có
configuration.php   chưa có
```

Sau khi cài thành công:

```text
configuration.php   đã được tạo
installation/       được xóa hoặc không còn sử dụng
```

Không xóa `installation/` trước khi hoàn tất cài đặt.

Không tự tạo file `configuration.php` rỗng.

---

## 9. Khởi động project

```bash
docker compose up -d --build
```

Kiểm tra container:

```bash
docker compose ps
```

Kết quả mong đợi:

```text
joomla6-app            running
joomla6-db             running (healthy)
joomla6-phpmyadmin     running
```

---

## 10. Mở Joomla Installer

Truy cập:

```text
http://localhost:8080
```

Các bước cài đặt:

### Bước 1: Site Configuration

Ví dụ:

```text
Site Name: Joomla 6 Local
```

### Bước 2: Administrator Account

Ví dụ:

```text
Real Name: Local Administrator
Username: admin
Password: mật khẩu mạnh
Email: admin@example.com
```

Tài khoản này dùng để đăng nhập Joomla Admin, không phải tài khoản MySQL.

### Bước 3: Database Configuration

Điền theo `.env`:

| Field | Value |
|---|---|
| Database Type | `MySQLi` |
| Host Name | `mysql` |
| Username | `joomla` |
| Password | `joomla_password` |
| Database Name | `joomla6` |
| Table Prefix | Giữ giá trị Joomla tạo sẵn |
| Connection Encryption | Default |

Trong Docker, host phải là `mysql` vì đây là tên service trong `docker-compose.yml`.

Không dùng:

```text
localhost
localhost:3307
host.docker.internal
```

Port `3307` chỉ dành cho kết nối từ máy host vào container. Joomla container kết nối MySQL nội bộ qua `mysql:3306`.

---

## 11. Nếu Joomla yêu cầu xác minh database host

Joomla có thể xem hostname `mysql` là remote host và yêu cầu xác minh quyền sở hữu.

Hãy làm đúng hướng dẫn trên màn hình, thường là tạo hoặc xóa một file có tên ngẫu nhiên trong:

```text
src/installation/
```

Ví dụ:

```bash
touch src/installation/<ten-file-joomla-yeu-cau>
```

Không tự đặt tên file. Dùng chính xác tên Joomla hiển thị.

---

## 12. File `configuration.php`

Sau khi bấm **Install Joomla**, Joomla sẽ:

1. Kết nối database.
2. Tạo các bảng Joomla.
3. Tạo tài khoản Administrator.
4. Lưu cấu hình website.
5. Tạo file `src/configuration.php`.

Các giá trị database quan trọng trong file:

```php
public $dbtype = 'mysqli';
public $host = 'mysql';
public $user = 'joomla';
public $password = 'joomla_password';
public $db = 'joomla6';
public $dbprefix = 'abc12_';
```

Không tự đổi `dbprefix` sau khi cài vì prefix phải khớp với tên các bảng trong database.

---

## 13. Nếu Joomla không tạo được `configuration.php`

Kiểm tra quyền ghi:

```bash
docker compose exec -u www-data joomla touch /var/www/html/test-write.txt
```

Nếu lệnh bị lỗi, cấp quyền lại ở local:

```bash
docker compose exec joomla chown -R www-data:www-data /var/www/html
```

Xóa file test:

```bash
docker compose exec joomla rm -f /var/www/html/test-write.txt
```

Nếu installer hiển thị nội dung cấu hình để copy thủ công:

1. Tạo `src/configuration.php`.
2. Copy đúng toàn bộ nội dung Joomla cung cấp.
3. Kiểm tra syntax:

```bash
docker compose exec joomla php -l /var/www/html/configuration.php
```

Không nên tự viết file từ đầu.

---

## 14. Truy cập sau khi cài

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

---

## 15. Reset để cài lại

```bash
docker compose down -v
rm -f src/configuration.php
```

Sau đó đảm bảo `src/installation/` vẫn tồn tại rồi chạy lại:

```bash
docker compose up -d --build
```

Lưu ý: `docker compose down -v` sẽ xóa toàn bộ dữ liệu database.

---

## Checklist

- [ ] Đã tải Joomla Full Package.
- [ ] `src/index.php` tồn tại.
- [ ] `src/installation/` tồn tại trước khi cài.
- [ ] MySQL container ở trạng thái healthy.
- [ ] Database host trong installer là `mysql`.
- [ ] User, password và database khớp `.env`.
- [ ] Joomla đã tạo các bảng database.
- [ ] `src/configuration.php` đã được tạo.
- [ ] Truy cập được `/administrator`.
