<?php
declare(strict_types=1);
require_once __DIR__ . '/config/funciones.php';
require_once __DIR__ . '/config/conexion.php';
try {
    $pdo = conexion();
    $cursos = $pdo->query("SELECT id,codigo,nombre FROM cursos WHERE estado='activo' ORDER BY nombre")->fetchAll();
    $materiales = $pdo->query("SELECT m.titulo,m.tipo,m.unidad,m.estado,c.nombre AS curso FROM materiales m JOIN cursos c ON c.id=m.curso_id ORDER BY m.id DESC")->fetchAll();
} catch (PDOException $e) {
    http_response_code(500);
    exit('No se pudo conectar con MySQL. Importa el SQL y revisa config/conexion.php');
}
cabecera('Materiales académicos', 'Registro de metadatos vinculados a cursos; archivos PDF en etapa posterior');
?>
<div class="grid">
    <section class="panel panel-form">
        <h2>Nuevo material (metadatos)</h2>
        <form method="post" action="acciones/guardar_material.php">
            <input type="hidden" name="csrf_token" value="<?= esc(token_csrf()) ?>">
            <div class="campo"><label for="curso_id">Curso</label><select id="curso_id" name="curso_id" required>
                    <option value="">Selecciona un curso</option><?php foreach ($cursos as $c): ?>
                        <option value="<?= (int) $c['id'] ?>"><?= esc($c['codigo'] . ' — ' . $c['nombre']) ?></option>
                    <?php endforeach; ?>
                </select></div>
            <div class="campo"><label for="titulo">Título</label><input type="text" id="titulo" name="titulo"
                    maxlength="200" required placeholder="Guía de lectura de la unidad 1"></div>
            <div class="dos-campos">
                <div class="campo"><label for="tipo">Tipo</label><select name="tipo" id="tipo"
                        required><?php foreach (['guia' => 'Guía', 'apuntes' => 'Apuntes', 'diapositivas' => 'Diapositivas', 'separata' => 'Separata', 'articulo' => 'Artículo', 'reglamento' => 'Reglamento', 'otro' => 'Otro'] as $valor => $etiqueta): ?>
                            <option value="<?= esc($valor) ?>"><?= esc($etiqueta) ?></option><?php endforeach; ?>
                    </select></div>
                <div class="campo"><label for="unidad">Unidad</label><input type="text" id="unidad" name="unidad"
                        maxlength="100" placeholder="Unidad 1"></div>
            </div>
            <div class="campo"><label for="descripcion">Descripción (opcional)</label><textarea id="descripcion"
                    name="descripcion" maxlength="1500" rows="2" placeholder="Descripción breve"></textarea></div>
            <div class="form-acciones"><button type="submit">Guardar metadatos</button></div>
        </form>
    </section>
    <section class="panel panel-listado">
        <h2>Materiales registrados</h2>
        <div class="tabla-responsive">
            <table>
                <thead>
                    <tr>
                        <th>Título</th>
                        <th>Curso</th>
                        <th>Tipo</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($materiales as $m): ?>
                        <tr>
                            <td><?= esc($m['titulo']) ?></td>
                            <td><?= esc($m['curso']) ?></td>
                            <td class="tipo"><?= esc(ucfirst($m['tipo'])) ?></td>
                        </tr><?php endforeach; ?>
                    <?php if (!$materiales): ?>
                        <tr>
                            <td colspan="3">Aún no hay materiales registrados.</td>
                        </tr><?php endif; ?>
                </tbody>
            </table>
        </div>
        <p><a class="link-suave" href="detalle.php">Ver diseño conceptual de detalle futuro</a></p>
    </section>
</div>
<?php pie(); ?>