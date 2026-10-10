/*
Ejercicio 3
Vuelo = (codVuelo, fecha, hora, cod_ciudad_origen, cod_ciudad_destino, cantidad_pasajes, codAerolinea)
Pasaje = (codReserva, asiento, codVuelo, codCliente, precio)
Aerolinea = (codAerolinea, nombre, origen)
Cliente = (codCliente, nombre, apellido, pasaporte, nacionalidad)
Ciudad = (codCiudad, nombre, pais) // país string con el nombre del país correspondiente
*/

/*1. Listar datos personales de clientes que viajaron con todas las aerolíneas.*/

SELECT c.*
FROM Cliente c
WHERE NOT EXISTS (
    SELECT *
    FROM Aerolinea a 
    WHERE NOT EXISTS (
        SELECT *
        FROM Vuelo v
        INNER JOIN Pasaje p  ON (v.codVuelo = c.codVuelo)
        WHERE (c.codCliente = p.codCliente) AND (v.codAerolinea = a.codAerolinea)
    )
);

/*2. Reportar para cada cliente, la cantidad de vuelos realizados con destino buenos aires. Se debe
informar datos personales del cliente y cantidad de vuelos.*/

SELECT c.nombre, c.apellido, c.nacionalidad, COUNT(cd.nombre) AS CantVuelos
FROM Cliente c
LEFT JOIN Pasaje p ON (c.codCliente = p.codCliente)
LEFT JOIN Vuelo v ON (p.codVuelo = v.codVuelo)
LEFT JOIN Ciudad cd ON (v.cod_ciudad_destino = cd.codCiudad)
WHERE cd.nombre = 'Buenos Aires'
GROUP BY c.codCliente, c.nombre, c.apellido, c.nacionalidad;


/*3. Listar información de vuelos sobrevendidos, vendió más pasajes que los disponibles para el vuelo.
Indicar codVuelo, fecha, hora, ciudad desde donde sale el vuelo y la ciudad donde llega.*/

SELECT v.codVuelo, v.fecha, v.hora, v.cod_ciudad_origen, v.cod_ciudad_destino
FROM Vuelo v
INNER JOIN Pasaje p ON (v.codVuelo=p.codVuelo)
INNER JOIN Ciudad co ON (v.cod_ciudad_origen=co.cod_ciudad_origen)
INNER JOIN Ciudad cd ON (v.cod_ciudad_destino=cd.cod_ciudad_destino)
GROUP BY v.codVuelo, v.fecha, v.hora, co.nombre, cd.nombre, v.cantidad_pasajes
HAVING COUNT(*) > v.cantidad_pasajes;

/*4. Listar datos personales de clientes que solo hayan viajado durante 2018. Ordenar por apellido y
nombre*/

SELECT c.apellido,c.nombre,c.nacionalidad
FROM Cliente c
WHERE EXISTS(
    SELECT *
    FROM Pasaje p 
    INNER JOIN Vuelo v ON (v.codVuelo=p.codVuelo)
    WHERE (c.codClienteliente=p.codCliente) AND (YEAR(v.fecha)=2018)
)
AND NOT EXISTS(
    SELECT *
    FROM Pasaje p 
    INNER JOIN Vuelo v ON (v.codVuelo=p.codVuelo)
    WHERE (c.codClienteliente=p.codCliente) AND (YEAR(v.fecha)<>2018)
)
ORDER BY c.apellido, c.nombre;

/*5. Listar para cada ciudad la cantidad de pasajeros que llegaron durante 2018. Indicar nombre, país y
cantidad de pasajeros.*/

SELECT c.nombre, c.pais, COUNT(DISTINCT p.codCliente) AS CantPasajeros
FROM Ciudad c
INNER JOIN Vuelo v ON (c.codCiudad = v.cod_ciudad_destino)
INNER JOIN Pasaje p ON (v.codVuelo = p.codVuelo)
WHERE YEAR(v.fecha) = 2018
GROUP BY c.nombre, c.pais;

/*6. Borrar el vuelo con código de vuelo LOM3524.*/

DELETE FROM Vuelo
WHERE codVuelo= 'LOM3524';

/*7. Listar datos personales de cliente que realizaron viajes con destino ‘Cancún’ durante 2018, pero no
volaron durante 2019*/

SELECT c.apellido, c.nombre, c.nacionalidad
FROM Cliente c
WHERE EXISTS(
    SELECT *
    FROM Pasaje p
    INNER JOIN Vuelo v ON (v.codVuelo=p.codVuelo)
    INNER JOIN Ciudad cd ON(v.cod_ciudad_destino=cd.codCiudad)
    WHERE (c.codCliente=p.codCliente) AND (cd.nombre='Cancun') AND (YEAR(v.fecha)=2018)
)
AND NOT EXISTS(
    SELECT *
    FROM Pasaje p
    INNER JOIN Vuelo v ON (v.codVuelo=p.codVuelo)
    WHERE (c.codCliente=p.codCliente) AND (YEAR(v.fecha)=2019)
);

/*8. Reportar información de vuelos con destino ‘Buenos Aires’ o que tengan pasajeros con nacionalidad
ucraniana.*/

SELECT *
FROM Vuelo v
INNER JOIN Ciudad cd ON (v.cod_ciudad_destino=cd.codCiudad)
WHERE (cd.nombre='Buenos Aires') 
OR EXISTS(
    SELECT *
    FROM Cliente c
    INNER JOIN Pasaje p ON (c.codCliente=p.codCliente)
    WHERE (p.codVuelo=v.codVuelo) AND (c.nacionalidad='Ucrania')
);

/*9. Listar datos personales de clientes que volaron con destino ‘Salta’ y también realizaron vuelos con
destino ‘Jujuy’.*/

SELECT c.apellido,c.nombre,c.nacionalidad
FROM Cliente c
WHERE EXISTS(
    SELECT *
    FROM Ciudad cd
    INNER JOIN Vuelo v ON (v.cod_ciudad_destino=cd.codCiudad)
    INNER JOIN Pasaje p ON (p.codVuelo=v.codVuelo)
    WHERE (p.codCliente=c.codCliente) AND (cd.nombre='Salta')
) AND EXISTS(
    SELECT *
    FROM Ciudad cd
    INNER JOIN Vuelo v ON (v.cod_ciudad_destino=cd.codCiudad)
    INNER JOIN Pasaje p ON (p.codVuelo=v.codVuelo)
    WHERE (p.codCliente=c.codCliente) AND (cd.nombre='Jujuy')
);

/*10. Listar información de aerolíneas que solo tengan vuelos con destino ‘Argentina’. Informar nombre y
origen.*/

SELECT a.nombre, a.origen
FROM Aerolinea a
WHERE EXISTS(
    SELECT *
    FROM Vuelo v
    INNER JOIN cd ON (v.cod_ciudad_destino=cd.codCiudad)
    WHERE (a.codAerolinea=v.codAerolinea) AND (cd.pais='Argentina')
) 
AND NOT EXISTS(
    SELECT *
    FROM Vuelo v
    INNER JOIN Ciudad cd ON (v.cod_ciudad_destino=cd.codCiudad)
    WHERE (a.codAerolinea=v.codAerolinea) AND (cd.pais<>'Argentina')
);