# PHP Introduction

## Table of Contents

- [What Is PHP?](#what-is-php)
- [What Can PHP Do?](#what-can-php-do)
- [How PHP Works](#how-php-works)
- [PHP and JavaScript](#php-and-javascript)
- [Your First PHP Example](#your-first-php-example)
- [Common PHP Applications](#common-php-applications)
- [Learning Checklist](#learning-checklist)
- [Official Resources](#official-resources)

---

## What Is PHP?

PHP is a server-side programming language mainly used to build websites, web applications, and APIs.

PHP originally meant **Personal Home Page**, but it now stands for:

> PHP: Hypertext Preprocessor

PHP files normally use the `.php` extension.

```text
index.php
```

Unlike frontend JavaScript, PHP usually runs on the server. The server processes the PHP source code and sends only the generated result, such as HTML or JSON, to the browser.

---

## What Can PHP Do?

PHP can be used to:

- Generate dynamic HTML pages.
- Process HTML forms.
- Connect to databases such as MySQL.
- Create login and registration systems.
- Manage sessions and cookies.
- Upload and process files.
- Build REST APIs.
- Send emails.
- Create command-line tools.
- Build content management systems.

---

## How PHP Works

```mermaid
flowchart LR
    A[User opens a URL] --> B[Browser sends HTTP request]
    B --> C[Web server receives request]
    C --> D[PHP executes the PHP file]
    D --> E[PHP may read files or query a database]
    E --> F[PHP generates HTML or JSON]
    F --> G[Web server returns HTTP response]
    G --> H[Browser displays the result]
```

Example request:

```text
http://localhost/index.php
```

PHP source code:

```php
<?php

echo 'Hello, World!';
```

The browser receives the generated output:

```text
Hello, World!
```

The browser does not normally receive the original PHP source code.

---

## PHP and JavaScript

| PHP | JavaScript |
| --- | --- |
| Usually runs on the server | Usually runs in the browser |
| Can connect to a database through server-side code | Browser code should not connect directly to a database |
| Generates HTML, JSON, files, or other responses | Updates the browser interface |
| Source code normally remains on the server | Frontend source code is sent to the browser |
| Commonly uses `.php` files | Commonly uses `.js` files |

PHP and JavaScript are often used together. PHP prepares data on the server, while JavaScript makes the page interactive in the browser.

---

## Your First PHP Example

Create a file named `index.php`:

```php
<?php

$message = 'Welcome to PHP';

echo $message;
```

Run it from the command line:

```bash
php index.php
```

Or start PHP's built-in development server:

```bash
php -S localhost:8000
```

Then open:

```text
http://localhost:8000
```

---

## Common PHP Applications

Popular platforms and applications that use PHP include:

- Joomla
- WordPress
- Drupal
- Magento
- Laravel applications
- Symfony applications
- Yii applications

---

## Learning Checklist

- [ ] I understand that PHP usually runs on the server.
- [ ] I know that PHP files use the `.php` extension.
- [ ] I understand the basic browser-server request flow.
- [ ] I can explain the difference between PHP and browser JavaScript.
- [ ] I can create and run a basic PHP file.

---

## Official Resources

- [Official PHP website](https://www.php.net/)
- [PHP manual](https://www.php.net/manual/en/)
- [PHP introduction](https://www.php.net/manual/en/intro-whatis.php)
- [PHP command-line documentation](https://www.php.net/manual/en/features.commandline.php)
