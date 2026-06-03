# CC3088 - Laboratorio de Bases de Datos

Infraestructura reproducible para el laboratorio con Docker Compose, PostgreSQL y Metabase.

## Estructura del proyecto

```text
.
|-- docker-compose.yml
|-- metabase-data/
|-- README.md
`-- sql/
    |-- 00-seed-metabase.sql
    |-- DDL.sql
    `-- DATA.sql
```

## Requisitos

- Docker Engine instalado.
- Docker Compose v2 (`docker compose`).
- Puertos libres:
  - `5433` para PostgreSQL
  - `3000` para Metabase

## Como correr el proyecto

1. Asegurate de estar en la raiz del proyecto.
2. Levanta los servicios:

```bash
docker compose up
```

Si quieres correrlo en segundo plano:

```bash
docker compose up -d
```

3. Abre Metabase en:

```text
http://localhost:3000
```

## Que hace esta solucion

- PostgreSQL arranca con la base del laboratorio `retailmax`.
- PostgreSQL ejecuta automaticamente los scripts de `sql/` al crear el volumen por primera vez.
- `00-seed-metabase.sql` crea el usuario y la base de datos interna que Metabase necesita.
- `DDL.sql` crea:
  - la estructura del laboratorio
- `DATA.sql` carga los datos de prueba.
- Metabase guarda dashboards, colecciones, usuarios y configuraciones dentro de PostgreSQL.
- Todo queda persistido en el volumen Docker `metabase-data`.

## Como detenerlo

```bash
docker compose down
```

## Como borrar datos persistidos

La persistencia real esta en el volumen Docker `metabase-data`.

### Opcion 1: borrar el contenido manualmente

1. Deten el stack:

```bash
docker compose down
```

2. Borra el contenido de `metabase-data/`.

### Opcion 2: borrar todo con Compose y luego limpiar la carpeta

```bash
docker compose down -v
```

Ese comando borra los volúmenes nombrados del proyecto y reinicia el estado persistente de la base de datos.

### Opcion 3: borrar y reiniciar desde cero

```bash
docker compose down
```

Luego elimina la carpeta `metabase-data/` y vuelve a levantar:

```bash
docker compose up
```

> Importante: PostgreSQL solo ejecuta los scripts de inicializacion cuando la carpeta de datos esta vacia.

## Persistencia y volumenes

### 1. PostgreSQL

La base de datos de PostgreSQL se monta en:

```text
./metabase-data -> /var/lib/postgresql/data
```

Eso significa que:

- los datos sobreviven a reinicios de contenedores
- los dashboards de Metabase sobreviven porque Metabase usa PostgreSQL como base de aplicacion
- si eliminas `metabase-data/`, pierdes tanto los datos del laboratorio como la metadata de Metabase

### 2. Metabase

Metabase no guarda los dashboards en archivos sueltos dentro del contenedor cuando usa PostgreSQL como base de aplicacion.
Los guarda en su base interna `metabaseappdb`, que tambien queda persistida dentro de `metabase-data/`.

## Como funcionan los init scripts de PostgreSQL

La imagen oficial de PostgreSQL ejecuta scripts ubicados en:

```text
/docker-entrypoint-initdb.d/
```

Reglas practicas:

- solo se ejecutan en el primer arranque, cuando la carpeta de datos esta vacia
- se procesan en orden alfabetico
- se aceptan archivos `.sql`, `.sql.gz` y `.sh`

En este proyecto:

- `00-seed-metabase.sql` crea el usuario y la base de Metabase
- `DDL.sql` crea tablas, relaciones y la base de Metabase
- `DATA.sql` inserta los registros de ejemplo

## Como Metabase persiste dashboards

Metabase guarda su configuracion interna en una base de datos de aplicacion.
En este proyecto esa base es PostgreSQL, configurada con variables `MB_DB_*`.

Campos clave:

- `MB_DB_TYPE=postgres`
- `MB_DB_HOST=postgres`
- `MB_DB_DBNAME=metabaseappdb`
- `MB_DB_USER=metabase`
- `MB_DB_PASS=metabase_password`

Con eso:

- dashboards
- preguntas
- colecciones
- usuarios
- permisos

quedan persistidos en PostgreSQL y sobreviven reinicios.

## Troubleshooting basico

### 1. Metabase no abre en `http://localhost:3000`

Revisa si el contenedor esta arriba:

```bash
docker compose ps
```

Mira los logs:

```bash
docker logs cc3088-metabase
```

### 2. PostgreSQL no arranca

Mira los logs:

```bash
docker logs cc3088-postgres
```

Si ves errores de inicializacion:

- verifica que `metabase-data/` este vacio si quieres reinicializar
- confirma que el puerto `5433` no este ocupado por otro servicio

### 3. Cambie los SQL pero no se reflejan

Eso es normal si la carpeta `metabase-data/` ya contiene datos.
PostgreSQL no vuelve a ejecutar los scripts de `/docker-entrypoint-initdb.d/` en arranques posteriores.

Para forzar una nueva inicializacion:

1. deten el stack
2. elimina `metabase-data/`
3. ejecuta otra vez `docker compose up`

### 4. Puerto 5433 o 3000 ocupado

Verifica que proceso lo usa:

```bash
docker ps
```

o en Windows:

```powershell
netstat -ano | findstr :5433
netstat -ano | findstr :3000
```

## Comandos utiles

### Arranque

```bash
docker compose up
docker compose up -d
```

### Detener

```bash
docker compose down
```

### Ver volumenes

```bash
docker volume ls
```

En este proyecto la persistencia principal es un bind mount local, por lo que `docker volume ls` puede no mostrar un volumen propio del laboratorio.

### Ver contenedores

```bash
docker ps
docker compose ps
```

### Ver logs

```bash
docker logs cc3088-postgres
docker logs cc3088-metabase
docker compose logs
docker compose logs -f
```

### Reiniciar servicios

```bash
docker compose restart
docker compose restart postgres
docker compose restart metabase
```

### Reconstruccion limpia de la base

```bash
docker compose down
```

Luego borra `metabase-data/` y vuelve a levantar:

```bash
docker compose up
```

## Archivos que debes crear manualmente

Si partes desde cero, crea estos elementos en la raiz del proyecto:

- `docker-compose.yml`
- `README.md`
- `sql/00-seed-metabase.sql`
- `sql/DDL.sql`
- `sql/DATA.sql`
- `metabase-data/`

En este entorno ya quedan preparados para que solo ejecutes:

```bash
docker compose up
```
