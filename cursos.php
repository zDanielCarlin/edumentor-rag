<?php
declare(strict_types=1);
require_once __DIR__ . '/config/funciones.php';
require_once __DIR__ . '/config/conexion.php';
try {
  $pdo = conexion();
  $docentes = $pdo->query("SELECT id,nombres,apellidos FROM usuarios WHERE rol='docente' AND estado='activo' ORDER BY apellidos")->fetchAll();
  $cursos = $pdo->query("SELECT c.codigo,c.nombre,c.descripcion,c.estado,CONCAT(u.nombres,' ',u.apellidos) AS docente FROM cursos c JOIN usuarios u ON u.id=c.docente_id ORDER BY c.id DESC")->fetchAll();
} catch (PDOException $e) {
  http_response_code(500);
  exit('No se pudo conectar con MySQL. Importa el SQL y revisa config/conexion.php');
}
cabecera('Gestión de cursos', 'Registrar cursos y consultar los registros persistidos en MySQL');
?>
<div class="grid">
  <section class="panel panel-form">
    <h2>Registrar curso</h2>
    <form method="post" action="acciones/guardar_curso.php">
      <input type="hidden" name="csrf_token" value="<?= esc(token_csrf()) ?>">
      <div class="campo"><label for="docente_id">Docente</label><select id="docente_id" name="docente_id" required>
          <option value="">Docente de demostración</option><?php foreach ($docentes as $d): ?>
            <option value="<?= (int) $d['id'] ?>"><?= esc($d['nombres'] . ' ' . $d['apellidos']) ?></option>
          <?php endforeach; ?>
        </select></div>
      <div class="dos-campos">
        <div class="campo"><label for="codigo">Código</label><input type="text" id="codigo" name="codigo" maxlength="30"
            placeholder="ADI-2026-01" required></div>
        <div class="campo"><label for="nombre">Nombre</label><input type="text" id="nombre" name="nombre"
            maxlength="160" placeholder="Aplicaciones Distribuidas I" required></div>
      </div>
      <div class="campo"><label for="descripcion">Descripción (opcional)</label><textarea id="descripcion"
          name="descripcion" maxlength="1500" rows="2" placeholder="Descripción breve"></textarea></div>
      <div class="form-acciones"><button type="submit">Guardar curso en MySQL</button></div>
    </form>
  </section>
  <section class="panel panel-listado">
    <h2>Cursos almacenados</h2>
    <div class="tabla-responsive">
      <table>
        <thead>
          <tr>
            <th>Código</th>
            <th>Nombre</th>
            <th>Estado</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($cursos as $c): ?>
            <tr>
              <td><?= esc($c['codigo']) ?></td>
              <td><?= esc($c['nombre']) ?></td>
              <td class="estado"><?= esc(ucfirst($c['estado'])) ?></td>
            </tr><?php endforeach; ?>
          <?php if (!$cursos): ?>
            <tr>
              <td colspan="3">Aún no hay cursos registrados.</td>
            </tr><?php endif; ?>
        </tbody>
      </table>
    </div>
  </section>
</div>
<?php pie(); ?>