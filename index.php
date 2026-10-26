<?php
declare(strict_types=1);
require_once __DIR__.'/config/funciones.php';
cabecera('Plataforma de apoyo académico','Prototipo de Semana 6: gestión inicial de cursos y materiales');
?>
<div class="grid grid-home">
  <section class="panel panel-home">
    <h2>Bienvenido a EduMentor RAG</h2>
    <p>Consulta los módulos del primer avance.</p>
    <p>La integración de IA se incorporará después.</p>
    <div class="acciones"><a href="cursos.php" class="boton">Administrar cursos</a><a href="materiales.php" class="boton secundario">Ver materiales</a></div>
  </section>
  <aside class="panel panel-proxima"><h2>Próxima etapa</h2><p>• Procesamiento documental</p><p>• Recuperación RAG</p><p>• Respuestas con fuentes</p></aside>
</div>
<?php pie(); ?>
