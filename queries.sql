/* ============================================================
   LAB 7 - DASHBOARD RECURSOS HUMANOS (RRHH)
   Empresa: RetailMax
   Esquema: rrhh
   ============================================================ */


/* ============================================================
   INDICADOR 1
   Carga de trabajo por empleado por tienda

   Mide la cantidad de pedidos atendidos por empleado
   en cada tienda.
   ============================================================ */
SELECT t.id_tienda,
       t.nombre,
       COUNT(DISTINCT e.id_empleado) AS empleados,
       COUNT(DISTINCT p.id_pedido) AS pedidos,
       ROUND(
           COUNT(DISTINCT p.id_pedido)::numeric /
           NULLIF(COUNT(DISTINCT e.id_empleado), 0),
           2
       ) AS pedidos_por_empleado
FROM rrhh.tienda t
LEFT JOIN rrhh.empleado e
       ON e.id_tienda = t.id_tienda
LEFT JOIN rrhh.pedido p
       ON p.id_tienda = t.id_tienda
GROUP BY t.id_tienda, t.nombre
ORDER BY pedidos_por_empleado DESC;


/* ============================================================
   INDICADOR 2
   Antigüedad promedio por tienda

   Calcula la cantidad promedio de años que los empleados
   han trabajado en cada sucursal.
   ============================================================ */
SELECT t.nombre,
       AVG(
           date_part(
               'year',
               age(current_date, e.fecha_contratacion)
           )
       ) AS antiguedad_promedio_anos
FROM rrhh.tienda t
LEFT JOIN rrhh.empleado e
       ON e.id_tienda = t.id_tienda
GROUP BY t.nombre
ORDER BY antiguedad_promedio_anos DESC;


/* ============================================================
   INDICADOR 3
   Distribución por puesto

   Muestra la cantidad de empleados por cargo.
   ============================================================ */
SELECT puesto,
       COUNT(*) AS cantidad
FROM rrhh.empleado
GROUP BY puesto
ORDER BY cantidad DESC;


/* ============================================================
   INDICADOR 4
   Relación empleados administrativos vs operativos

   Compara la cantidad de personal administrativo
   contra el personal operativo.
   ============================================================ */
SELECT
    SUM(
        CASE
            WHEN puesto ILIKE '%admin%'
              OR puesto ILIKE '%geren%'
              OR puesto ILIKE '%encarg%'
            THEN 1
            ELSE 0
        END
    ) AS administrativos,

    SUM(
        CASE
            WHEN puesto ILIKE '%oper%'
              OR puesto ILIKE '%vendedor%'
              OR NOT (
                  puesto ILIKE '%admin%'
                  OR puesto ILIKE '%geren%'
                  OR puesto ILIKE '%encarg%'
              )
            THEN 1
            ELSE 0
        END
    ) AS operativos
FROM rrhh.empleado;


/* ============================================================
   INDICADOR 5
   Cantidad de empleados por tienda

   Muestra el tamaño de la fuerza laboral por sucursal.
   ============================================================ */
SELECT t.nombre,
       COUNT(e.id_empleado) AS empleados
FROM rrhh.tienda t
LEFT JOIN rrhh.empleado e
       ON e.id_tienda = t.id_tienda
GROUP BY t.nombre
ORDER BY empleados DESC;


/* ============================================================
   INDICADOR 6
   Distribución de empleados por región

   Cuenta la cantidad de empleados agrupados por región.
   ============================================================ */
SELECT t.region,
       COUNT(e.id_empleado) AS total_empleados
FROM rrhh.empleado e
JOIN rrhh.tienda t
     ON e.id_tienda = t.id_tienda
GROUP BY t.region;


/* ============================================================
   INDICADOR 7
   Evolución mensual de costos salariales

   Calcula la evolución histórica de la nómina total.
   ============================================================ */
WITH meses AS (
    SELECT generate_series(
        date_trunc(
            'month',
            (
                SELECT MIN(fecha_contratacion)
                FROM rrhh.empleado
            )
        ),
        date_trunc('month', current_date),
        interval '1 month'
    ) AS mes_inicio
)
SELECT m.mes_inicio,
       SUM(e.salario)::numeric(14,2) AS total_nomina_mes
FROM meses m
JOIN rrhh.empleado e
     ON e.fecha_contratacion <= (
         m.mes_inicio
         + interval '1 month'
         - interval '1 day'
     )
GROUP BY m.mes_inicio
ORDER BY m.mes_inicio;


/* ============================================================
   INDICADOR 8
   Salario promedio por puesto

   Obtiene el salario promedio para cada cargo.
   ============================================================ */
SELECT puesto,
       AVG(salario)::numeric(12,2) AS salario_promedio
FROM rrhh.empleado
GROUP BY puesto
ORDER BY salario_promedio DESC;


/* ============================================================
   INDICADOR 9
   Costo total de nómina por tienda

   Calcula el gasto total en salarios por sucursal.
   ============================================================ */
SELECT t.nombre,
       SUM(e.salario)::numeric(14,2) AS total_nomina
FROM rrhh.empleado e
JOIN rrhh.tienda t
     ON e.id_tienda = t.id_tienda
GROUP BY t.nombre
ORDER BY total_nomina DESC;


/* ============================================================
   INDICADOR 10
   Comparación salarial entre regiones

   Muestra el salario promedio por región.
   ============================================================ */
SELECT t.region,
       AVG(e.salario)::numeric(12,2) AS salario_promedio
FROM rrhh.empleado e
JOIN rrhh.tienda t
     ON e.id_tienda = t.id_tienda
GROUP BY t.region
ORDER BY salario_promedio DESC;


/* ============================================================
   INDICADOR 11
   Top 10 empleados con mayor salario

   Lista los colaboradores con los salarios más altos.
   ============================================================ */
SELECT nombre,
       puesto,
       salario,
       id_tienda
FROM rrhh.empleado
ORDER BY salario DESC
LIMIT 10;


/* ============================================================
   INDICADOR 12
   Porcentaje de pedidos devueltos por tienda

   Calcula el porcentaje de devoluciones respecto
   al total de pedidos de cada sucursal.
   ============================================================ */
SELECT t.nombre,
       ROUND(
           100.0 * COUNT(d.id_devolucion) /
           NULLIF(COUNT(p.id_pedido), 0),
           2
       ) AS pct_devoluciones
FROM rrhh.tienda t
LEFT JOIN rrhh.pedido p
       ON p.id_tienda = t.id_tienda
LEFT JOIN rrhh.devolucion d
       ON d.id_pedido = p.id_pedido
GROUP BY t.nombre
ORDER BY pct_devoluciones DESC;