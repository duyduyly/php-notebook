CREATE DATABASE IF NOT EXISTS joomla_migration CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE joomla_migration;

CREATE TABLE IF NOT EXISTS migration_runs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    run_uuid CHAR(36) NOT NULL UNIQUE,
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    status ENUM('running','completed','failed','rolled_back') NOT NULL DEFAULT 'running',
    source_version VARCHAR(50) NULL,
    target_version VARCHAR(50) NULL,
    notes TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS migration_id_map (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    run_id BIGINT UNSIGNED NOT NULL,
    entity_type VARCHAR(64) NOT NULL,
    source_id BIGINT UNSIGNED NOT NULL,
    target_id BIGINT UNSIGNED NULL,
    status ENUM('pending','migrated','skipped','failed','manual_review') NOT NULL DEFAULT 'pending',
    error_message TEXT NULL,
    UNIQUE KEY uq_run_entity_source (run_id, entity_type, source_id),
    KEY idx_run_entity_target (run_id, entity_type, target_id),
    CONSTRAINT fk_mapping_run FOREIGN KEY (run_id) REFERENCES migration_runs(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS migration_exceptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    run_id BIGINT UNSIGNED NOT NULL,
    entity_type VARCHAR(64) NOT NULL,
    source_id BIGINT UNSIGNED NULL,
    severity ENUM('warning','error','manual_review') NOT NULL,
    code VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exception_run FOREIGN KEY (run_id) REFERENCES migration_runs(id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO migration_runs (run_uuid, source_version, target_version, notes)
SELECT UUID(), '3.10.x', '6.x', 'Example migration run'
WHERE NOT EXISTS (SELECT 1 FROM migration_runs);
