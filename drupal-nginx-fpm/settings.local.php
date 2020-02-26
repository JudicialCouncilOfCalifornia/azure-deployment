<?php

// @codingStandardsIgnoreFile

//  Store local configuration separately so it isn't tracked by git.
$config['config_split.config_split.local']['status'] = TRUE;
$config['config_split.config_split.stage']['status'] = TRUE;

$databases['default']['default'] = array(
    'database' => $_ENV["DATABASE_NAME"],
    'username' => $_ENV["DATABASE_USER"],
    'password' => $_ENV["DATABASE_PASSWORD"],
    'host' => $_ENV["DATABASE_HOST"],
    'driver' => 'mysql',
    'port' => 3306,
    'prefix' => '',
);
