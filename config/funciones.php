<?php
declare(strict_types=1);

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}
function esc(?string $v): string {
    return htmlspecialchars((string)$v, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}
function largo(string $valor): int {
    return function_exists('mb_strlen') ? mb_strlen($valor, 'UTF-8') : strlen($valor);
}
function token_csrf(): string {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return (string)$_SESSION['csrf_token'];
}
function validar_csrf(): void {
    if (!hash_equals(token_csrf(), (string)($_POST['csrf_token'] ?? ''))) {
        http_response_code(403);
        exit('Solicitud no valida (CSRF).');
    }
}
function notificacion(string $tipo, string $mensaje): void {
    $_SESSION['notificacion'] = ['tipo' => $tipo, 'mensaje' => $mensaje];
}
function mostrar_notificacion(): void {
    if (!isset($_SESSION['notificacion'])) return;
    $x = $_SESSION['notificacion'];
    unset($_SESSION['notificacion']);
    echo '<p class="aviso '.esc($x['tipo']).'">'.esc($x['mensaje']).'</p>';
}
function cabecera(string $titulo, string $subtitulo=''): void {
    $tituloSeguro=esc($titulo);
    $subtituloSeguro=esc($subtitulo);
    $archivo=basename((string)($_SERVER['SCRIPT_NAME'] ?? 'index.php'));
    $enlaces=['index.php'=>'Inicio','cursos.php'=>'Cursos','materiales.php'=>'Materiales'];
    echo '<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'.$tituloSeguro.' | EduMentor RAG</title><link rel="stylesheet" href="css/estilos.css"></head><body><header><div class="barra"><a class="marca" href="index.php"><span class="marca-icono" aria-hidden="true"></span><span>EduMentor RAG</span></a><nav aria-label="Navegación principal">';
    foreach($enlaces as $url=>$label){echo '<a href="'.esc($url).'"'.($archivo===$url?' aria-current="page"':'').'>'.esc($label).'</a>';}
    echo '</nav></div></header><main><div class="encabezado"><h1>'.$tituloSeguro.'</h1><p class="subtitulo">'.$subtituloSeguro.'</p></div>';
    mostrar_notificacion();
}
function pie(): void {
    echo '</main><footer>PROTOTIPO FUNCIONAL · SEMANA 6 · Registro y consulta real en MySQL · IA pendiente</footer></body></html>';
}
