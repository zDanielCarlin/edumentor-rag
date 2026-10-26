<?php
declare(strict_types=1);
require_once __DIR__ . '/../config/funciones.php';
require_once __DIR__ . '/../config/conexion.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Método no permitido');
}
validar_csrf();
$docente = filter_var($_POST['docente_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
$codigo = strtoupper(trim((string) ($_POST['codigo'] ?? '')));
$nombre = trim((string) ($_POST['nombre'] ?? ''));
$descripcion = trim((string) ($_POST['descripcion'] ?? ''));
if (!$docente || $codigo === '' || strlen($codigo) > 30 || $nombre === '' || largo($nombre) > 160 || largo($descripcion) > 1500) {
    notificacion('error', 'Revisa los datos del formulario.');
    header('Location: ../cursos.php');
    exit;
}
try {
    $pdo = conexion();
    $q = $pdo->prepare("SELECT id FROM usuarios WHERE id=? AND rol='docente' AND estado='activo'");
    $q->execute([$docente]);
    if (!$q->fetch())
        throw new RuntimeException('El docente seleccionado no es válido.');
    $q = $pdo->prepare('INSERT INTO cursos (docente_id, codigo, nombre, descripcion) VALUES (?,?,?,?)');
    $q->execute([$docente, $codigo, $nombre, $descripcion !== '' ? $descripcion : null]);
    notificacion('exito', 'Curso registrado correctamente en MySQL.');
} catch (PDOException $e) {
    notificacion('error', $e->getCode() === '23000' ? 'El código del curso ya existe.' : 'No fue posible registrar el curso.');
} catch (RuntimeException $e) {
    notificacion('error', $e->getMessage());
}
header('Location: ../cursos.php');
exit;
