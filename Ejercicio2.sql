/*
Cliente = (codCliente, nombreYAp, DNI, telefono, direccion, sexo, edad)
Esteticista = (codEst, nombre, apellido, DNI, fecha_nac, especialidad)
Producto = (codProd, nombreP, descripcion, stock, precio)
ProductoAplicado = (nroAplicacion, codProd, cantidad, precio) // precio del producto al momento de
realizar la aplicación al cliente
Aplicacion = (nroAplicacion, codEst, codCliente, costoTotal, fecha)
*/

/*1. Listar datos personales de esteticistas que solo hayan atendido durante 2019, ordenar por nombre y
apellidos y DNI ascendentemente.*/

SELECT *
FROM Esteticista e
WHERE NOT EXISTS(
    SELECT *
    FROM Aplicacion a
    WHERE (a.codEst=e.codEst) AND (YEAR(a.fecha)<>2019)
)   AND EXISTS(
        SELECT *
        FROM Aplicacion a
        WHERE (a.codEst=e.codEst) AND (YEAR(a.fecha)=2019)
)
ORDER BY e.nombre, e.apellido, e.DNI

/*2. Listar promedio de edad de clientes tratados con productos que terminen con el String ‘ura’.*/

SELECT AVG(c.edad) AS Prom_Edad
FROM Cliente c
WHERE EXISTS (
SELECT *
FROM Aplicacion a
JOIN ProductoAplicado pa ON pa.nroAplicacion = a.nroAplicacion
JOIN Producto p ON p.codProd = pa.codProd
WHERE (a.codCliente = c.codCliente) AND (p.nombreP LIKE '%ura')
);

/*3. Listar para cada producto, la cantidad de aplicaciones en las que fue utilizado. Indicar nombre,
descripción, stock, precio y cantidad de aplicaciones. Ordenar por cantidad de aplicaciones.*/

SELECT p.nombreP, p.descripcion, p.stock, p.precio, COUNT(*) AS CantAplicaciones
FROM Producto p
LEFT JOIN ProductoAplicado pa ON(p.codProd=pa.codProd)
GROUP BY p.codProd p.nombreP, p.descripcion, p.stock, p.precio
ORDER BY CantAplicaciones;

/*4. Listar datos personales de esteticistas que no realizaron ninguna aplicación a clientes menores de
25 años.*/

SELECT *
FROM Esteticista e
WHERE NOT EXISTS(
    SELECT *
    FROM Aplicacion a
    INNER JOIN Cliente c ON (c.codCliente=a.codCliente)
    WHERE (c.codEst=a.codEst) AND (c.edad<25)
);

/*5. Actualizar el precio de los productos de nombre ‘tintura’ incrementando 20% su valor actual.*/

UPDATE Producto p
SET p.precio = p.precio * 1.20
WHERE p.nombreP = 'tintura';

/*6. Listar datos personales de clientes que se realizaron alguna aplicación durante 2018 pero no se
atendieron en 2019.*/

SELECT *
FROM Cliente c
WHERE EXISTS(
    SELECT *
    FROM Aplicacion a
    WHERE (a.codCliente=c.codCliente) and YEAR(a.fecha)=2018
)
AND NOT EXISTS(
    SELECT *
    FROM Aplicacion a
    WHERE (a.codCliente=c.codCliente) and YEAR(a.fecha)=2019
);

/*
Cliente = (codCliente, nombreYAp, DNI, telefono, direccion, sexo, edad)
Esteticista = (codEst, nombre, apellido, DNI, fecha_nac, especialidad)
Producto = (codProd, nombreP, descripcion, stock, precio)
ProductoAplicado = (nroAplicacion, codProd, cantidad, precio) // precio del producto al momento de
realizar la aplicación al cliente
Aplicacion = (nroAplicacion, codEst, codCliente, costoTotal, fecha)
*/

/*7. Reportar nombre, descripción,stock y precio de productos que se utilizaron en mujeres y que tengan
alguna aplicación donde el precio al momento de la aplicación fue inferior a $500.*/

SELECT DISTINCT p.nombreP, p.descripcion, p.stock, p.precio
FROM Producto p
INNER JOIN ProductoAplicado pa ON (pa.codProd=p.codProd)
INNER JOIN Aplicacion a ON (pa.nroAplicacion=a.nroAplicacion)
INNER JOIN Cliente c ON (a.codCliente=c.codCliente)
WHERE (c.sexo='Mujer') AND (pa.precio<500);

/*8. Listar información de productos utilizados en las aplicaciones realizadas al cliente con DNI:
38329663.*/

SELECT DISTINCT p.*
FROM Producto p
INNER JOIN ProductoAplicado pa ON (pa.codProd=p.codProd)
INNER JOIN Aplicacion a ON (pa.nroAplicacion=a.nroAplicacion)
INNER JOIN Cliente c ON (a.codCliente=c.codCliente)
WHERE c.DNI=38329663;

/*9. Listar datos de productos utilizados por todos los esteticistas.*/

SELECT p.*
FROM Producto p
WHERE NOT EXISTS (
    SELECT *
    FROM Esteticista e
    WHERE NOT EXISTS (
        SELECT *
        FROM ProductoAplicado pa
        INNER JOIN Aplicacion a ON (a.nroAplicacion = pa.nroAplicacion)
        WHERE (pa.codProd = p.codProd) AND (a.codEst = e.codEst)
    )
);

/*10. Listar el cliente o los clientes que gastaron más en la peluqueria (suma de costo total de sus
aplicaciones).*/

SELECT c.*
FROM Cliente c
INNER JOIN Aplicacion a ON (a.codCliente = c.codCliente)
GROUP BY c.codCliente, c.nombreYAp, c.DNI, c.telefono, c.direccion, c.sexo, c.edad
HAVING SUM(a.costoTotal) >= ALL (
    SELECT SUM(a2.costoTotal)
    FROM Aplicacion a2
    GROUP BY a2.codCliente
);
