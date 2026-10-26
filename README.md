# EduMentor RAG

**Prototipo web — Semana 6**

Proyecto académico desarrollado para el curso **Aplicaciones Distribuidas I** de la Universidad Nacional del Santa.

## 1. Descripción del proyecto

EduMentor RAG es una plataforma web de apoyo académico orientada a la gestión de cursos y materiales educativos.

Este repositorio contiene el prototipo funcional correspondiente al primer avance (Semana 6). La integración de inteligencia artificial y recuperación aumentada por generación (RAG) se contempla para etapas posteriores.

## 2. Tecnologías utilizadas

- PHP
- HTML5
- CSS3
- MySQL 8
- Apache
- Laragon
- HeidiSQL
- Git y GitHub

## 3. Estructura del proyecto

- `acciones/`: archivos PHP para registrar cursos y materiales.
- `config/`: conexión con MySQL y funciones auxiliares.
- `css/`: estilos de la interfaz.
- `sql/`: scripts de creación y verificación de la base de datos.
- `index.php`: página principal.
- `cursos.php`: gestión de cursos.
- `materiales.php`: gestión de materiales educativos.
- `detalle.php`: visualización de información detallada.

## 4. Requisitos para la ejecución

Se necesita:

- Windows con Laragon instalado.
- Apache y MySQL activos.
- PHP con extensión PDO MySQL habilitada.
- Un navegador web.

## 5. Instalación del proyecto

**Paso 1.** Descargar este repositorio desde GitHub.

**Paso 2.** Extraer los archivos del proyecto dentro de la carpeta:

`C:\laragon\www\APLICACIONES DISTRIBUIDAS`

**Paso 3.** Abrir Laragon e iniciar los servicios Apache y MySQL.

## 6. Importación de la base de datos

1. Abrir HeidiSQL desde Laragon.
2. Conectarse al servidor MySQL local.
3. Abrir el archivo `sql/TABLAS.sql`.
4. Ejecutar el script SQL.
5. Comprobar que se haya creado la base de datos `edumentor_db` con sus 11 tablas.

El archivo `sql/VERIFICAR.sql` contiene consultas para verificar la base de datos.

**Nota:** el script de creación está pensado para una instalación nueva. No debe ejecutarse nuevamente sobre una base de datos que ya tiene las tablas creadas.

## 7. Configuración de la conexión

La conexión a MySQL se configura en:

`config/conexion.php`

Los valores locales predeterminados son:

- Servidor: `127.0.0.1`
- Puerto: `3306`
- Base de datos: `edumentor_db`
- Usuario: `root`
- Contraseña: vacía

Estos datos pueden adaptarse mediante las variables de entorno `EDUMENTOR_DB_HOST`, `EDUMENTOR_DB_PORT`, `EDUMENTOR_DB_NAME`, `EDUMENTOR_DB_USER` y `EDUMENTOR_DB_PASS`.

**Importante:** no publicar contraseñas reales en el repositorio.

## 8. Ejecutar la aplicación

Con Apache y MySQL iniciados, abrir en el navegador:

`http://localhost/APLICACIONES%20DISTRIBUIDAS/index.php`

Desde la página principal se puede acceder a los módulos de cursos y materiales.

## 9. Comprobar la persistencia

Para verificar el funcionamiento de PHP con MySQL:

1. Ingresar al módulo **Cursos**.
2. Registrar un curso mediante el formulario.
3. Comprobar que el curso aparezca en la página.
4. Actualizar el navegador para confirmar que el registro permanece.
5. Abrir HeidiSQL y consultar la tabla `cursos` de la base de datos `edumentor_db`.

Consulta de comprobación:

`SELECT * FROM edumentor_db.cursos;`

Si el curso registrado aparece en HeidiSQL y en la aplicación, se confirma el almacenamiento y recuperación de información mediante PHP y MySQL.

## 10. Alcance de la Semana 6

Este avance comprende:

- Interfaz web navegable.
- Gestión inicial de cursos y materiales.
- Diseño e implementación de la base de datos.
- Persistencia de información en MySQL.
- Código fuente organizado y versionado en GitHub.

El sistema RAG con inteligencia artificial forma parte de la propuesta de desarrollo para los siguientes avances académicos.
