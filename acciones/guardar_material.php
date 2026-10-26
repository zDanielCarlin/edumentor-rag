<?php
declare(strict_types=1);
require_once __DIR__ . '/../config/funciones.php';
require_once __DIR__ . '/../config/conexion.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Método no permitido');
}
validar_csrf();
$curso = filter_var($_POST['curso_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
$titulo = trim((string) ($_POST['titulo'] ?? ''));
$tipo = (string) ($_POST['tipo'] ?? '');
$unidad = trim((string) ($_POST['unidad'] ?? ''));
$descripcion = trim((string) ($_POST['descripcion'] ?? ''));
$permitidos = ['separata', 'diapositivas', 'apuntes', 'guia', 'articulo', 'reglamento', 'otro'];
if (!$curso || $titulo === '' || largo($titulo) > 200 || !in_array($tipo, $permitidos, true) || largo($unidad) > 100 || largo($descripcion) > 1500) {
    notificacion('error', 'Revisa los datos del material.');
    header('Location: ../materiales.php');
    exit;
}
try {
    $pdo = conexion();
    $q = $pdo->prepare("SELECT c.docente_id FROM cursos c JOIN usuarios u ON u.id=c.docente_id WHERE c.id=? AND c.estado='activo' AND u.rol='docente' AND u.estado='activo'");
    $q->execute([$curso]);
    $registro = $q->fetch();
    if (!$registro)
        throw new RuntimeException('El curso seleccionado no está disponible.');
    $q = $pdo->prepare('INSERT INTO materiales (curso_id, registrado_por, titulo, descripcion, tipo, unidad, estado) VALUES (?,?,?,?,?,?,?)');
    $q->execute([$curso, $registro['docente_id'], $titulo, $descripcion !== '' ? $descripcion : null, $tipo, $unidad !== '' ? $unidad : null, 'borrador']);
    notificacion('exito', 'Metadatos del material registrados en MySQL (sin archivo).');
} catch (PDOException $e) {
    notificacion('error', 'No fue posible registrar el material.');
} catch (RuntimeException $e) {
    notificacion('error', $e->getMessage());
}
header('Location: ../materiales.php');
exit;
