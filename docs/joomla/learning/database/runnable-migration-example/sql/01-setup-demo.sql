-- WARNING: This script drops and recreates demo databases.
-- Do not run it against real Joomla databases.

DROP DATABASE IF EXISTS joomla3_demo;
DROP DATABASE IF EXISTS joomla6_demo;
DROP DATABASE IF EXISTS joomla_migration_demo;

CREATE DATABASE joomla3_demo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE DATABASE joomla6_demo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE DATABASE joomla_migration_demo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE joomla3_demo;

CREATE TABLE j3_categories (
    id INT UNSIGNED NOT NULL,
    parent_id INT UNSIGNED NOT NULL DEFAULT 1,
    title VARCHAR(255) NOT NULL,
    alias VARCHAR(255) NOT NULL,
    description TEXT NULL,
    published TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE j3_content (
    id INT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    alias VARCHAR(255) NOT NULL,
    introtext MEDIUMTEXT NULL,
    fulltext MEDIUMTEXT NULL,
    catid INT UNSIGNED NOT NULL,
    state TINYINT NOT NULL DEFAULT 1,
    created DATETIME NULL,
    images LONGTEXT NULL,
    metadata LONGTEXT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

INSERT INTO j3_categories (
    id,
    parent_id,
    title,
    alias,
    description,
    published
) VALUES
    (10, 1, 'News', 'news', 'Company news', 1),
    (11, 10, 'Product News', 'product-news', 'Product announcements', 1);

INSERT INTO j3_content (
    id,
    title,
    alias,
    introtext,
    fulltext,
    catid,
    state,
    created,
    images,
    metadata
) VALUES
    (
        100,
        'Welcome to the Migration Demo',
        'welcome-to-the-migration-demo',
        '<p>This article demonstrates a simple migration.</p>',
        '',
        10,
        1,
        '2026-08-05 08:00:00',
        '{"image_intro":"images/demo/welcome.jpg"}',
        '{"robots":"","author":"Migration Demo"}'
    ),
    (
        101,
        'New Product Announcement',
        'new-product-announcement',
        '<p>This article belongs to a child category.</p>',
        '<p>Full product announcement content.</p>',
        11,
        1,
        '0000-00-00 00:00:00',
        '',
        ''
    );

USE joomla6_demo;

CREATE TABLE j6_categories (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    parent_id INT UNSIGNED NOT NULL DEFAULT 1,
    title VARCHAR(255) NOT NULL,
    alias VARCHAR(255) NOT NULL,
    description TEXT NULL,
    published TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_category_alias_parent (alias, parent_id)
) ENGINE=InnoDB;

CREATE TABLE j6_content (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    alias VARCHAR(255) NOT NULL,
    introtext MEDIUMTEXT NULL,
    fulltext MEDIUMTEXT NULL,
    catid INT UNSIGNED NOT NULL,
    state TINYINT NOT NULL DEFAULT 1,
    created DATETIME NULL,
    images LONGTEXT NOT NULL,
    metadata LONGTEXT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_content_alias_category (alias, catid),
    CONSTRAINT fk_content_category
        FOREIGN KEY (catid) REFERENCES j6_categories (id)
) ENGINE=InnoDB;

INSERT INTO j6_categories (
    id,
    parent_id,
    title,
    alias,
    description,
    published
) VALUES
    (1, 0, 'ROOT', 'root', 'Target root category', 1);

USE joomla_migration_demo;

CREATE TABLE migration_category_map (
    source_id INT UNSIGNED NOT NULL,
    target_id INT UNSIGNED NULL,
    status ENUM('pending', 'migrated', 'failed') NOT NULL DEFAULT 'pending',
    error_message TEXT NULL,
    migrated_at DATETIME NULL,
    PRIMARY KEY (source_id),
    UNIQUE KEY uq_category_target_id (target_id)
) ENGINE=InnoDB;

CREATE TABLE migration_content_map (
    source_id INT UNSIGNED NOT NULL,
    target_id INT UNSIGNED NULL,
    status ENUM('pending', 'migrated', 'failed') NOT NULL DEFAULT 'pending',
    error_message TEXT NULL,
    migrated_at DATETIME NULL,
    PRIMARY KEY (source_id),
    UNIQUE KEY uq_content_target_id (target_id)
) ENGINE=InnoDB;
