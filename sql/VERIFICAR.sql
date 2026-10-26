-- EDUMENTOR RAG | PRUEBAS EXPLORATORIAS DE SEMANA 6
-- Ejecutar tras importar 01 y 02. Capturar pantallas con resultados reales.
USE edumentor_db;

-- CP-01: comprobar tablas (deben existir 11 tablas de usuario).
SHOW FULL TABLES;

-- CP-02: comprobar claves foraneas declaradas.
SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA='edumentor_db' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- CP-03: cursos con su docente.
SELECT c.id, c.codigo, c.nombre, c.estado,
       CONCAT(u.nombres, ' ', u.apellidos) AS docente
FROM cursos c JOIN usuarios u ON u.id=c.docente_id
ORDER BY c.id;

-- CP-04: materiales con su curso.
SELECT m.id, m.titulo, m.tipo, m.estado, c.codigo AS codigo_curso, c.nombre AS curso
FROM materiales m JOIN cursos c ON c.id=m.curso_id
ORDER BY m.id;

-- CP-05: alumnos inscritos por curso.
SELECT c.codigo, CONCAT(u.nombres, ' ', u.apellidos) AS estudiante, i.estado
FROM inscripciones i JOIN cursos c ON c.id=i.curso_id
JOIN usuarios u ON u.id=i.estudiante_id ORDER BY c.codigo;

-- CP-06: tabla de futuras consultas vacia en la demo (NO respuestas simuladas).
SELECT COUNT(*) AS consultas_ia_reales FROM consultas;

-- CP-07: estructura detallada de tablas de persistencia de Semana 6.
SHOW CREATE TABLE cursos;
SHOW CREATE TABLE materiales;
