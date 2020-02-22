<?php

// @codingStandardsIgnoreFile

$databases['default']['default'] = array(
    'database' => $_ENV["DATABASE_NAME"],
    'username' => $_ENV["DATABASE_USERNAME"],
    'password' => $_ENV["DATABASE_PASSWORD"],
    'host' => $_ENV["DATABASE_HOST"],
    'driver' => 'mysql',
    'port' => 3306,
    'prefix' => '',
);
