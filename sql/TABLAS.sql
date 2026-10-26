-- EDUMENTOR RAG: IMPORTACION EN UN SOLO PASO.
-- Usar solo en una base sin las 11 tablas. Datos son sinteticos.

-- ===========================================================================
-- EDUMENTOR RAG | ESQUEMA RELACIONAL | SEMANA 6 | VERSION 1.0
-- MySQL 8.0.16+ / MariaDB 10.4+ | InnoDB | utf8mb4
-- Requisitos: RF-01..RF-23 del analisis preliminar de EduMentor RAG.
-- Semana 6: se demuestra registro/listado de cursos y materiales.
-- Fases siguientes: documentos, RAG, fuentes, valoraciones y reportes.
-- NO ejecuta DROP DATABASE ni DROP TABLE. No contiene datos de prueba.
-- IMPORTANTE: importar en una instalacion que NO tenga estas tablas.
-- ===========================================================================

CREATE DATABASE IF NOT EXISTS edumentor_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE edumentor_db;

-- BD-01 | RF-01, RF-02 | Docentes y estudiantes.
CREATE TABLE usuarios (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombres VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  correo VARCHAR(190) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  rol ENUM('docente', 'estudiante') NOT NULL,
  estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuarios_correo (correo),
  KEY idx_usuarios_rol (rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-02 | RF-03, RF-04 | Un docente responsable por curso.
CREATE TABLE cursos (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  docente_id BIGINT UNSIGNED NOT NULL,
  codigo VARCHAR(30) NOT NULL,
  nombre VARCHAR(160) NOT NULL,
  descripcion TEXT NULL,
  estado ENUM('activo', 'archivado') NOT NULL DEFAULT 'activo',
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cursos_codigo (codigo),
  KEY idx_cursos_docente_estado (docente_id, estado),
  CONSTRAINT fk_cursos_docente FOREIGN KEY (docente_id)
    REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-03 | Acceso del estudiante al curso: decision de diseno DEC-02.
CREATE TABLE inscripciones (
  curso_id BIGINT UNSIGNED NOT NULL,
  estudiante_id BIGINT UNSIGNED NOT NULL,
  estado ENUM('activa', 'inactiva') NOT NULL DEFAULT 'activa',
  inscrito_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (curso_id, estudiante_id),
  KEY idx_inscripciones_estudiante (estudiante_id, estado),
  CONSTRAINT fk_inscripciones_curso FOREIGN KEY (curso_id)
    REFERENCES cursos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_inscripciones_estudiante FOREIGN KEY (estudiante_id)
    REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-04 | RF-05, RF-08 | Material academico, independiente del archivo fisico.
CREATE TABLE materiales (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  curso_id BIGINT UNSIGNED NOT NULL,
  registrado_por BIGINT UNSIGNED NOT NULL,
  titulo VARCHAR(200) NOT NULL,
  descripcion TEXT NULL,
  tipo ENUM('separata', 'diapositivas', 'apuntes', 'guia', 'articulo', 'reglamento', 'otro') NOT NULL DEFAULT 'otro',
  unidad VARCHAR(100) NULL,
  tema VARCHAR(150) NULL,
  estado ENUM('borrador', 'publicado', 'archivado') NOT NULL DEFAULT 'borrador',
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_materiales_curso_estado (curso_id, estado),
  KEY idx_materiales_registrado_por (registrado_por),
  CONSTRAINT fk_materiales_curso FOREIGN KEY (curso_id)
    REFERENCES cursos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_materiales_registrado_por FOREIGN KEY (registrado_por)
    REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-05 | RF-06, RF-07 | Versiones para preservar referencias historicas.
-- Los archivos se almacenaran fuera de la carpeta publica; aqui solo metadatos.
CREATE TABLE versiones_material (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  material_id BIGINT UNSIGNED NOT NULL,
  numero_version INT UNSIGNED NOT NULL,
  nombre_archivo VARCHAR(255) NOT NULL,
  ruta_privada VARCHAR(500) NOT NULL,
  tipo_mime VARCHAR(120) NOT NULL,
  tamano_bytes BIGINT UNSIGNED NOT NULL,
  hash_sha256 CHAR(64) NOT NULL,
  estado_procesamiento ENUM('pendiente', 'procesando', 'listo', 'error') NOT NULL DEFAULT 'pendiente',
  detalle_error VARCHAR(500) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  procesado_en DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_versiones_material_numero (material_id, numero_version),
  KEY idx_versiones_estado (estado_procesamiento),
  CONSTRAINT fk_versiones_material FOREIGN KEY (material_id)
    REFERENCES materiales (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_versiones_numero CHECK (numero_version > 0),
  CONSTRAINT chk_versiones_tamano CHECK (tamano_bytes > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-06 | RF-07, RF-12, RF-15 | Fragmentos para recuperacion futura.
CREATE TABLE fragmentos (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  version_id BIGINT UNSIGNED NOT NULL,
  orden INT UNSIGNED NOT NULL,
  texto MEDIUMTEXT NOT NULL,
  pagina_inicio INT UNSIGNED NULL,
  pagina_fin INT UNSIGNED NULL,
  id_vector_externo VARCHAR(190) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_fragmentos_version_orden (version_id, orden),
  UNIQUE KEY uq_fragmentos_vector (id_vector_externo),
  FULLTEXT KEY ft_fragmentos_texto (texto),
  CONSTRAINT fk_fragmentos_version FOREIGN KEY (version_id)
    REFERENCES versiones_material (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_fragmentos_orden CHECK (orden > 0),
  CONSTRAINT chk_fragmentos_paginas CHECK (
    (pagina_inicio IS NULL AND pagina_fin IS NULL) OR
    (pagina_inicio IS NOT NULL AND pagina_inicio > 0 AND
     (pagina_fin IS NULL OR pagina_fin >= pagina_inicio))
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-07 | RF-09, RF-10 | Preguntas propuestas por el docente (DEC-04).
CREATE TABLE preguntas_banco (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  curso_id BIGINT UNSIGNED NOT NULL,
  creado_por BIGINT UNSIGNED NOT NULL,
  enunciado TEXT NOT NULL,
  respuesta_referencia TEXT NULL,
  estado ENUM('activa', 'archivada') NOT NULL DEFAULT 'activa',
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_preguntas_banco_curso (curso_id, estado),
  KEY idx_preguntas_banco_autor (creado_por),
  CONSTRAINT fk_preguntas_banco_curso FOREIGN KEY (curso_id)
    REFERENCES cursos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_preguntas_banco_autor FOREIGN KEY (creado_por)
    REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-08 | RF-11, RF-13, RF-14, RF-16, RF-19 | Consultas RAG futuras.
-- No insertar respuestas falsas en datos de demostracion de Semana 6.
CREATE TABLE consultas (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  curso_id BIGINT UNSIGNED NOT NULL,
  estudiante_id BIGINT UNSIGNED NOT NULL,
  pregunta TEXT NOT NULL,
  respuesta MEDIUMTEXT NULL,
  estado ENUM('pendiente', 'respondida', 'sin_evidencia', 'error') NOT NULL DEFAULT 'pendiente',
  proveedor_ia VARCHAR(100) NULL,
  modelo_ia VARCHAR(120) NULL,
  duracion_ms INT UNSIGNED NULL,
  detalle_error VARCHAR(500) NULL,
  consultado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  respondido_en DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_consultas_curso_fecha (curso_id, consultado_en),
  KEY idx_consultas_estudiante_fecha (estudiante_id, consultado_en),
  CONSTRAINT fk_consultas_curso FOREIGN KEY (curso_id)
    REFERENCES cursos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_consultas_estudiante FOREIGN KEY (estudiante_id)
    REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-09 | RF-15, RF-16 | Trazabilidad respuesta -> fragmento exacto.
CREATE TABLE consulta_fuentes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  consulta_id BIGINT UNSIGNED NOT NULL,
  fragmento_id BIGINT UNSIGNED NOT NULL,
  orden_fuente SMALLINT UNSIGNED NOT NULL,
  extracto_utilizado TEXT NOT NULL,
  registrado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_fuentes_consulta_fragmento (consulta_id, fragmento_id),
  UNIQUE KEY uq_fuentes_consulta_orden (consulta_id, orden_fuente),
  KEY idx_fuentes_fragmento (fragmento_id),
  CONSTRAINT fk_fuentes_consulta FOREIGN KEY (consulta_id)
    REFERENCES consultas (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_fuentes_fragmento FOREIGN KEY (fragmento_id)
    REFERENCES fragmentos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_fuentes_orden CHECK (orden_fuente > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-10 | RF-17, RF-19 | Una valoracion por consulta.
CREATE TABLE valoraciones (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  consulta_id BIGINT UNSIGNED NOT NULL,
  utilidad ENUM('util', 'parcialmente_util', 'no_util') NOT NULL,
  comentario VARCHAR(500) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_valoraciones_consulta (consulta_id),
  CONSTRAINT fk_valoraciones_consulta FOREIGN KEY (consulta_id)
    REFERENCES consultas (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BD-11 | RF-18 | Motivos previstos en los requisitos preliminares.
CREATE TABLE reportes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  consulta_id BIGINT UNSIGNED NOT NULL,
  motivo ENUM('informacion_incorrecta', 'informacion_incompleta', 'fuente_no_relacionada', 'respuesta_no_sustentada') NOT NULL,
  detalle TEXT NULL,
  estado ENUM('pendiente', 'revisado', 'resuelto') NOT NULL DEFAULT 'pendiente',
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_reportes_consulta (consulta_id),
  KEY idx_reportes_estado (estado),
  CONSTRAINT fk_reportes_consulta FOREIGN KEY (consulta_id)
    REFERENCES consultas (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CONSULTAS DE SEMANA 6: las tablas usuarios, cursos y materiales se usarán
-- en el prototipo PHP. Las demás quedan diseñadas para próximas semanas.


-- DATOS SINTETICOS DE DEMOSTRACION (NO son usuarios/observaciones reales).
-- Ejecutar DESPUES de 01_crear_edumentor.sql.
-- Password SOLO para DEMO LOCAL: Demo1234! (hash bcrypt; no subir secretos reales).
USE edumentor_db;

INSERT INTO usuarios (nombres, apellidos, correo, password_hash, rol)
VALUES
 ('Docente', 'Demo Uno', 'docente1@demo.edumentor.test', '$2y$12$Q3QIKExU4I0nnE/fEJkHPensVS6BEmRM8WEFPFbKR5HoYJTUzm4rS', 'docente'),
 ('Docente', 'Demo Dos', 'docente2@demo.edumentor.test', '$2y$12$Q3QIKExU4I0nnE/fEJkHPensVS6BEmRM8WEFPFbKR5HoYJTUzm4rS', 'docente'),
 ('Estudiante', 'Demo Uno', 'estudiante1@demo.edumentor.test', '$2y$12$Q3QIKExU4I0nnE/fEJkHPensVS6BEmRM8WEFPFbKR5HoYJTUzm4rS', 'estudiante'),
 ('Estudiante', 'Demo Dos', 'estudiante2@demo.edumentor.test', '$2y$12$Q3QIKExU4I0nnE/fEJkHPensVS6BEmRM8WEFPFbKR5HoYJTUzm4rS', 'estudiante')
ON DUPLICATE KEY UPDATE correo = VALUES(correo);

INSERT INTO cursos (docente_id, codigo, nombre, descripcion)
SELECT id, 'ADI-DEMO-01', 'Aplicaciones Distribuidas I',
       'Curso de demostracion con datos sinteticos de EduMentor RAG'
FROM usuarios WHERE correo='docente1@demo.edumentor.test'
ON DUPLICATE KEY UPDATE codigo = VALUES(codigo);

INSERT INTO cursos (docente_id, codigo, nombre, descripcion)
SELECT id, 'BD-DEMO-01', 'Bases de Datos',
       'Segundo curso de demostracion con datos sinteticos'
FROM usuarios WHERE correo='docente2@demo.edumentor.test'
ON DUPLICATE KEY UPDATE codigo = VALUES(codigo);

INSERT INTO inscripciones (curso_id, estudiante_id)
SELECT c.id, u.id FROM cursos c JOIN usuarios u
ON u.correo='estudiante1@demo.edumentor.test' WHERE c.codigo='ADI-DEMO-01'
ON DUPLICATE KEY UPDATE estado='activa';

INSERT INTO inscripciones (curso_id, estudiante_id)
SELECT c.id, u.id FROM cursos c JOIN usuarios u
ON u.correo='estudiante2@demo.edumentor.test' WHERE c.codigo='BD-DEMO-01'
ON DUPLICATE KEY UPDATE estado='activa';

INSERT INTO materiales (curso_id, registrado_por, titulo, descripcion, tipo, unidad, tema, estado)
SELECT c.id, c.docente_id, 'Guia inicial sobre sistemas distribuidos',
       'Material de ejemplo: NO contiene ningun archivo y NO esta procesado para RAG.',
       'guia', 'Unidad I', 'Conceptos fundamentales', 'borrador'
FROM cursos c
WHERE c.codigo='ADI-DEMO-01'
  AND NOT EXISTS (SELECT 1 FROM materiales m WHERE m.curso_id=c.id
                  AND m.titulo='Guia inicial sobre sistemas distribuidos');

INSERT INTO materiales (curso_id, registrado_por, titulo, descripcion, tipo, unidad, tema, estado)
SELECT c.id, c.docente_id, 'Separata introductoria de bases de datos',
       'Metadatos sinteticos para demostracion, sin archivo adjunto.',
       'separata', 'Unidad I', 'Modelo relacional', 'borrador'
FROM cursos c
WHERE c.codigo='BD-DEMO-01'
  AND NOT EXISTS (SELECT 1 FROM materiales m WHERE m.curso_id=c.id
                  AND m.titulo='Separata introductoria de bases de datos');

INSERT INTO preguntas_banco (curso_id, creado_por, enunciado, respuesta_referencia)
SELECT c.id, c.docente_id, '¿Que caracteriza a un sistema distribuido?', NULL
FROM cursos c
WHERE c.codigo='ADI-DEMO-01'
  AND NOT EXISTS (SELECT 1 FROM preguntas_banco p WHERE p.curso_id=c.id
                  AND p.enunciado='¿Que caracteriza a un sistema distribuido?');

-- IMPORTANTE: No se insertan consultas ni respuestas ficticias de IA.
