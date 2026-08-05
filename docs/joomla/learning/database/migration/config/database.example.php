<?php

declare(strict_types=1);

return [
    'source' => [
        'dsn' => 'mysql:host=127.0.0.1;dbname=joomla3_source;charset=utf8mb4',
        'username' => 'root',
        'password' => '',
        'prefix' => 'j3_',
    ],
    'target' => [
        'dsn' => 'mysql:host=127.0.0.1;dbname=joomla6_target;charset=utf8mb4',
        'username' => 'root',
        'password' => '',
        'prefix' => 'j6_',
    ],
    'migration' => [
        'dsn' => 'mysql:host=127.0.0.1;dbname=joomla_migration;charset=utf8mb4',
        'username' => 'root',
        'password' => '',
    ],
    'joomla_root' => '/var/www/html/joomla6',
];
