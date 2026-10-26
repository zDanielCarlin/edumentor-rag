<?php
declare(strict_types=1);
require_once __DIR__ . '/config/funciones.php';
cabecera('Detalle de material', 'Vista conceptual para la etapa de incorporación documental y RAG');
?>
<div class="grid grid-detail">
    <section class="panel panel-detalle">
        <h2>Guía de lectura: Unidad 1</h2>
        <p class="resumen">Curso: Aplicaciones Distribuidas I</p>
        <p class="resumen">Tipo: Guía · Versión: v1 · Estado: autorizado</p>
        <p class="detalle-final muted">Archivo y fragmentos recuperables (futuro)</p>
    </section>
    <aside class="panel panel-futuro">
        <h2>Asistente académico</h2>
        <p class="asistente-ayuda">Pregunta sobre el material…</p><textarea disabled
            aria-label="Pregunta al asistente RAG" placeholder="Funcionalidad futura"></textarea><button
            class="btn-futuro" disabled>Consultar RAG</button>
    </aside>
</div>
<?php pie(); ?>