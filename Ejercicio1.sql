/*
Ejercicio 1
Esquema mínimo propuesto para poder resolver los incisos.

Idea general:
- Cliente y Venta para el punto 2, 3 y 5.
- Libro y Genero para el punto 1 y 6.
- Prestamo y DetallePrestamo para el punto 3, 5, 7 y 9.
- Autor, Nacionalidad y LibroAutor para el punto 4 y 10.
- DetalleVenta para saber qué libros se vendieron en cada venta.

Esquema:
Genero = (idGenero PK, nombre)
Nacionalidad = (idNacionalidad PK, nombre)
Cliente = (idCliente PK, dni, nombre, telefono, direccion)
Libro = (idLibro PK, titulo, idGenero FK, isbn, precioVenta, precioPrestamo, habilitadoVenta, habilitadoPrestamo)
Autor = (idAutor PK, nombre, apellido, idNacionalidad FK)
LibroAutor = (idLibro PK/FK, idAutor PK/FK)
Venta = (idVenta PK, fecha, hora, idCliente FK)
DetalleVenta = (idVenta PK/FK, idLibro PK/FK, cantidad, precioUnitario)
Prestamo = (idPrestamo PK, fechaPrestamo, fechaTentativaDevolucion, fechaDevolucion, idCliente FK)
DetallePrestamo = (idPrestamo PK/FK, idLibro PK/FK, cantidad)
*/

/*
Incisos comentados como guía. No están resueltos a propósito.

1) Listar los libros del género Fantasía.
   - Tabla principal: Libro.
   - Relación necesaria: Libro -> Genero.
   - Pensar en un filtro por nombre de género y un ORDER BY por título y género.
*/
SELECT *
FROM Libro l
INNER JOIN Genero g ON (l.idGenero = g.idGenero)
WHERE g.nombre = 'Fantasía'
ORDER BY l.titulo, g.nombre;

/*
2) Listar todas las ventas realizadas con fecha, hora, cliente y libros vendidos.
   - Tablas: Venta, Cliente, DetalleVenta y Libro.
   - Una venta puede tener varios libros, así que hay que unir cabecera con detalle.
*/

SELECT v.fecha, v.hora, c.nombre, l.titulo
FROM Venta v
INNER JOIN Cliente c ON v.idCliente = c.idCliente
INNER JOIN DetalleVenta dv ON v.idVenta = dv.idVenta
INNER JOIN Libro l ON dv.idLibro = l.idLibro;

/*
3) Listar clientes con préstamos vencidos y sin devolución.
   - Tablas: Cliente y Prestamo.
   - La pista está en comparar fechaTentativaDevolucion con la fecha actual y revisar que fechaDevolucion sea nula.
*/

SELECT *
FROM Cliente C
INNER JOIN Prestamo P ON (C.idCliente=P.idCliente)
WHERE P.fechaTentativaDevolucion<GETDATE() AND P.fechaDevolucion IS NULL

/*
4) Listar libros que tienen solo autores de nacionalidad Argentina.
   - Tablas: Libro, LibroAutor, Autor y Nacionalidad.
   - La clave está en que no aparezca ningún autor no argentino para ese libro.
*/

SELECT l.*
FROM Libro l
WHERE NOT EXISTS (
    SELECT 1
    FROM LibroAutor la
    INNER JOIN Autor a ON la.idAutor = a.idAutor
    INNER JOIN Nacionalidad n ON a.idNacionalidad = n.idNacionalidad
    WHERE la.idLibro = l.idLibro
      AND n.nombre <> 'Argentina'
);

/*
5) Listar clientes que solo tienen préstamos.
   - Tablas: Cliente, Prestamo y también Venta para excluir clientes que hayan comprado.
   - Pensar en clientes que sí figuran en préstamos y no figuran en ventas.
*/

SELECT *
FROM Cliente c
WHERE EXISTS(
    SELECT *
    FROM Prestamo p
    WHERE (p.idCliente=c.idCliente)
)
AND NOT EXISTS(
    SELECT *
    FROM Venta v
    WHERE (v.idCliente=c.idCliente)
);

/*
6) Listar libros que están a la venta pero no para préstamos.
   - Tabla principal: Libro.
   - Basta con usar las banderas habilitadoVenta y habilitadoPrestamo.
*/
SELECT *
FROM Libro l
WHERE (l.habilitadoVenta=1) and (l.habilitadoPrestamo=0)

/*
7) Mostrar para cada libro la cantidad de préstamos.
   - Tablas: Libro y DetallePrestamo.
   - Acá aparece agregación: contar cuántas veces se prestó cada libro.
*/

SELECT l.idLibro, l.titulo, COUNT(dp.idLibro) AS CantPrestamos
FROM Libro l
LEFT JOIN DetallePrestamo dp ON dp.idLibro = l.idLibro
GROUP BY l.idLibro, l.titulo; 


/*
8) Mostrar la cantidad de ventas para abril del año actual.
   - Tabla principal: Venta.
   - Filtro por mes y año de la fecha.
*/
SELECT COUNT(*) AS CantVentas
FROM Venta V
WHERE YEAR(V.fecha)=2026 AND MONTH(V.fecha)=4;

/*
9) Listar los préstamos del año actual que tengan más de 3 libros.
   - Tablas: Prestamo y DetallePrestamo.
   - Hay que agrupar por préstamo y contar la cantidad de libros asociados.
*/

SELECT p.idPrestamo, p.fechaPrestamo, COUNT(*) AS CantLibros
FROM Prestamo p
INNER JOIN DetallePrestamo dp ON dp.idPrestamo = p.idPrestamo
WHERE YEAR(p.fechaPrestamo) = YEAR(GETDATE())
GROUP BY p.idPrestamo, p.fechaPrestamo
HAVING COUNT(*) > 3;


/*
10) Listar los autores que tengan más de 10 libros.
	- Tablas: Autor y LibroAutor.
	- Acá se agrupa por autor y se cuenta cuántos libros tiene vinculados.
*/

SELECT a.idAutor, a.nombre, a.apellido, COUNT(*) AS CantLibros
FROM Autor a
INNER JOIN LibroAutor la ON(a.idAutor=la.idAutor)
GROUP BY a.idAutor, a.nombre, a.apellido
HAVING COUNT(*) > 10;
