<?php

declare(strict_types=1);

$shared = [
    'username' => 'root',
    'password' => '',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ],
];

return [
    'source' => $shared + [
        'dsn' => 'mysql:host=127.0.0.1;port=3306;dbname=joomla3_demo;charset=utf8mb4',
    ],
    'target' => $shared + [
        'dsn' => 'mysql:host=127.0.0.1;port=3306;dbname=joomla6_demo;charset=utf8mb4',
    ],
    'migration' => $shared + [
        'dsn' => 'mysql:host=127.0.0.1;port=3306;dbname=joomla_migration_demo;charset=utf8mb4',
    ],
];
