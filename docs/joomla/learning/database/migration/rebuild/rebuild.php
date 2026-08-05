#!/usr/bin/env php
<?php

declare(strict_types=1);

$configFile = dirname(__DIR__) . '/config/database.php';

if (!is_file($configFile)) {
    fwrite(STDERR, "Missing config/database.php. Copy database.example.php first.\n");
    exit(1);
}

$config = require $configFile;
$joomlaRoot = rtrim((string) ($config['joomla_root'] ?? ''), DIRECTORY_SEPARATOR);

if ($joomlaRoot === '' || !is_file($joomlaRoot . '/includes/defines.php')) {
    fwrite(STDERR, "Invalid Joomla root: {$joomlaRoot}\n");
    exit(1);
}

define('_JEXEC', 1);
define('JPATH_BASE', $joomlaRoot);

require_once JPATH_BASE . '/includes/defines.php';
require_once JPATH_BASE . '/includes/framework.php';

use Joomla\CMS\Factory;
use Joomla\CMS\Table\Table;

try {
    $container = Factory::getContainer();
    $db = $container->get(\Joomla\Database\DatabaseInterface::class);

    foreach ([['Category', '#__categories'], ['Menu', '#__menu'], ['Tag', '#__tags']] as [$type, $name]) {
        $table = Table::getInstance($type, 'JTable', ['dbo' => $db]);

        if (!method_exists($table, 'rebuild')) {
            fwrite(STDOUT, "Skip {$name}: rebuild() is unavailable.\n");
            continue;
        }

        if (!$table->rebuild()) {
            throw new RuntimeException("Failed to rebuild {$name}.");
        }

        fwrite(STDOUT, "Rebuilt {$name}.\n");
    }

    fwrite(STDOUT, "Tree rebuild completed. Validate ACL assets, workflows, cache, and Smart Search separately.\n");
    exit(0);
} catch (Throwable $exception) {
    fwrite(STDERR, "Rebuild failed: {$exception->getMessage()}\n");
    exit(1);
}
