<?php
declare(strict_types=1);

function conexion(): PDO
{
    $host = getenv('EDUMENTOR_DB_HOST') ?: '127.0.0.1';
    $puerto = getenv('EDUMENTOR_DB_PORT') ?: '3306';
    $base = getenv('EDUMENTOR_DB_NAME') ?: 'edumentor_db';
    $usuario = getenv('EDUMENTOR_DB_USER') ?: 'root';
    $password = getenv('EDUMENTOR_DB_PASS') ?: '';

    $dsn = "mysql:host={$host};port={$puerto};dbname={$base};charset=utf8mb4";
    return new PDO($dsn, $usuario, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
}
