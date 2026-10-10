/*Cliente (DNI, nombre, apellido, telefono)
Vehículo (patente, marca, modelo, año, precio, dni_cliente (FK)?)
Servicio (id_servicio (PK), descripcion, precio_base)
Mantenimiento (patente (FK), id_servicio (FK), fecha, diagnostico, precioM)
Venta (patente (FK), dni_cliente (FK), fecha_venta, monto_final)
*/

/*1. Listar para cada cliente la cantidad de ventas. Ordenar por apellido y nombre.*/

SELECT c.apellido,c.nombre,c.DNI,c.telefono,COUNT(v.dni_cliente) AS CantVent
FROM Cliente c LEFT JOIN Venta v ON (c.DNI=v.dni_cliente)
GROUP BY c.apellido,c.nombre,c.DNI,c.telefono
ORDER BY c.apellido,c.nombre;

/*2. Listar la cantidad de vehículos que no están vendidos, es decir no tienen un cliente asociado.*/

SELECT COUNT(*) AS CantVehiculos
FROM Vehiculo v
WHERE NOT EXISTS(
    SELECT *
    FROM Venta ve
    WHERE v.patente=ve.patente
);

/*3. Eliminar el vehículo con patente MSH216.*/

DELETE FROM Mantenimiento
WHERE patente='MSH216';
DELETE FROM Venta
WHERE patente='MSH216';
DELETE FROM Vehiculo
WHERE patente='MSH216';

/*4. Listar los servicios que nunca fueron realizados en ningún mantenimiento.*/

SELECT s.*
FROM Servicio s
WHERE NOT EXISTS(
    SELECT *
    FROM Mantenimiento m
    WHERE s.id_servicio=m.id_servicio
);

/*5. Listar los vehículos que recibieron servicios en el año actual y también fueron vendidos en cualquier momento.*/

SELECT v.*
FROM Vehiculo v
WHERE EXISTS(
    SELECT *
    FROM Mantenimiento m INNER JOIN Servicio s ON (m.id_servicio=s.id_servicio)
    WHERE (v.patente = m.patente) AND YEAR(m.fecha)=YEAR(GETDATE())
) AND EXISTS(
    SELECT *
    FROM Venta ve
    WHERE ve.patente=v.patente
);

/*6. Listar los servicios que fueron utilizados más de 5 veces en el año actual. Ordenar por cantidad descendiente.*/

SELECT s.id_servicio , s.descripcion, s.precio_base, COUNT(*) AS Cantidad
FROM Servicio s INNER JOIN Mantenimiento m ON (s.id_servicio=m.id_servicio)
WHERE YEAR(m.fecha)=YEAR(GETDATE())
GROUP BY s.id_servicio , s.descripcion, s.precio_base
HAVING COUNT(*)>5
ORDER BY Cantidad DESC;