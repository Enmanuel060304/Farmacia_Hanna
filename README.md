# Farmacia Hanna – Base de Datos

Este repositorio contiene el script de creación del esquema de base de datos para la gestión integral de la Farmacia *Hanna*. El diseño cubre proveedores, productos (medicamentos), compras, ventas, devoluciones (clientes y proveedores) y control de inventario básico.

## Objetivos del Sistema
- Gestionar catálogo de medicamentos con precios, stock y vencimientos.
- Registrar compras a proveedores y el detalle de cada artículo adquirido.
- Registrar ventas a clientes y su detalle asociado.
- Administrar devoluciones de clientes (retorno al inventario o descarte) y devoluciones a proveedores (salida del inventario).
- Mantener trazabilidad de precios unitarios históricos y cantidades devueltas.
- Facilitar extensiones futuras (auditoría, reportes, control de lote, estados de devoluciones, usuarios con roles, etc.).

## Modelo de Datos (Resumen de Tablas)

### Catálogo y Referenciales
- **Proveedores**: Datos de contacto de los proveedores.
- **Categorias**: Clasificación de medicamentos.
- **Laboratorios**: Laboratorio / fabricante del medicamento.
- **Clientes**: Información básica de clientes finales.
- **Empleados**: Usuarios internos que realizan operaciones (ventas, devoluciones, etc.).

### Inventario y Productos
- **Medicamentos**: Información principal del producto. Incluye precios (compra, venta, promoción), stock actual, fechas (ingreso, vencimiento) y llaves foráneas a proveedor, categoría y laboratorio.

### Operaciones Comerciales
- **Compras**: Encabezado de compras a proveedores (con proveedor, total y fecha).
- **Detalles_Compras**: Ítems individuales de cada compra (cantidad, precio unitario y subtotal).
- **Ventas**: Encabezado de ventas a clientes (empleado, cliente, total y fecha).
- **Detalles_Ventas**: Ítems vendidos (cantidad, precio unitario y subtotal).

### Devoluciones
Separadas en dos flujos para claridad de reglas de negocio:
- **Devoluciones_Clientes**: Cabecera de devolución de una venta (empleado que registra, estado y motivo general).
- **Detalles_Devoluciones_Clientes**: Ítems devueltos por el cliente, con referencia opcional al detalle de venta original, control de si afectan stock y cálculo de subtotal persistido.
- **Devoluciones_Proveedores**: Cabecera de devolución al proveedor (puede referenciar una compra original) con estado y motivo general.
- **Detalles_Devoluciones_Proveedores**: Ítems devueltos al proveedor, con posible vínculo al detalle de compra original.

### Columnas Calculadas y Persistidas
- Algunas tablas de detalle usan `SubTotal` como columna calculada `PERSISTED` para mejorar rendimiento y permitir índices futuros, garantizando consistencia (Cantidad * Precio_Unitario).

## Relaciones Principales (Cardinalidades)
- Un **Proveedor** -> muchos **Medicamentos** y muchas **Compras**.
- Una **Compra** -> muchos **Detalles_Compras**.
- Una **Venta** -> muchos **Detalles_Ventas**.
- Un **Medicamento** -> aparece en múltiples detalles (ventas, compras, devoluciones de clientes y proveedores).
- Una **Devolución_Clientes** -> muchos **Detalles_Devoluciones_Clientes**.
- Una **Devolución_Proveedores** -> muchos **Detalles_Devoluciones_Proveedores**.

## Convenciones Técnicas
- Tipo de identificador: `UNIQUEIDENTIFIER` con `DEFAULT NEWID()` para garantizar unicidad global.
- Fechas: Se utiliza `GETDATE()` como valor por defecto para marcas de tiempo simples.
- Nombres: Estilo PascalCase / snake ligero en español manteniendo claridad de dominio.
- Monetarios: Se usan `DECIMAL(10,2)` para evitar limitaciones de `DECIMAL(2,2)` y permitir importes realistas.
- Integridad: Llaves foráneas nombradas de forma explícita (`FK_*`) para facilitar lectura y trazabilidad.

## Script Principal
El archivo principal del esquema es: `Schema/SchemaDb.sql`.

## Ejecución Rápida
1. Abrir SQL Server Management Studio (o entorno compatible).
2. Ejecutar el script completo `SchemaDb.sql` (incluye `CREATE DATABASE` y `USE`).
3. Verificar creación de tablas:
	```sql
	SELECT name FROM sys.tables ORDER BY name;
	```
4. (Opcional) Insertar datos de prueba básicos:
	```sql
	INSERT INTO Proveedores (Nombre, Contacto, Telefono, Direccion)
	VALUES ('Proveedor Genérico', 'Contacto 1', '000-000', 'Calle X');

	INSERT INTO Categorias (Nombre, Descripcion)
	VALUES ('Analgesicos', 'Dolor y fiebre');

	INSERT INTO Laboratorios (Nombre) VALUES ('Lab Salud');
	```

## Ejemplo: Flujo de Venta y Devolución de Cliente
```sql
-- Insertar cliente y empleado (asumiendo ya existen otros referenciales)
DECLARE @ClienteID UNIQUEIDENTIFIER = NEWID();
INSERT INTO Clientes (ID, Nombre, Telefono, Direccion)
VALUES (@ClienteID, 'Juan Perez', '555-111', 'Av. Principal 123');

DECLARE @EmpleadoID UNIQUEIDENTIFIER = NEWID();
INSERT INTO Empleados (ID, Nombre, Cedula, Telefono, Cargo, Usuario, Contraseña_Hash)
VALUES (@EmpleadoID, 'Maria Lopez', '001-0000000-1', '555-222', 'Cajera', 'mlopez', 'hash');

-- Insertar medicamento
DECLARE @MedID UNIQUEIDENTIFIER = NEWID();
INSERT INTO Medicamentos (ID, Nombre, Descripcion, Precio_Compra, Precio_Venta, Stock, Fecha_Vencimiento)
VALUES (@MedID, 'Paracetamol 500mg', 'Caja 10 tabletas', 20.00, 35.00, 100, '2026-12-31');

-- Crear venta
DECLARE @VentaID UNIQUEIDENTIFIER = NEWID();
INSERT INTO Ventas (ID, ID_Empleado, ID_Cliente, Total)
VALUES (@VentaID, @EmpleadoID, @ClienteID, 70.00);

-- Detalle venta (2 unidades)
DECLARE @DetVentaID UNIQUEIDENTIFIER = NEWID();
INSERT INTO Detalles_Ventas (ID, Cantidad, Precio_Unitario, SubTotal, ID_Venta, ID_Medicamento)
VALUES (@DetVentaID, 2, 35.00, 70.00, @VentaID, @MedID);

-- Registrar devolución parcial (1 unidad retorna a stock)
DECLARE @DevClienteID UNIQUEIDENTIFIER = NEWID();
INSERT INTO Devoluciones_Clientes (ID, ID_Venta, ID_Empleado, Motivo_General)
VALUES (@DevClienteID, @VentaID, @EmpleadoID, 'Cliente no necesitaba una caja');

INSERT INTO Detalles_Devoluciones_Clientes (ID_Devolucion, ID_Medicamento, ID_Detalle_Venta, Cantidad, Precio_Unitario, Motivo_Item, Afecta_Stock)
VALUES (@DevClienteID, @MedID, @DetVentaID, 1, 35.00, 'Sin abrir', 1);

-- Ajustar stock manual (en implementación real podría ser un trigger)
UPDATE Medicamentos SET Stock = Stock + 1 WHERE ID = @MedID;
```

## Ejemplo: Devolución a Proveedor
```sql
DECLARE @DevProvID UNIQUEIDENTIFIER = NEWID();
INSERT INTO Devoluciones_Proveedores (ID, ID_Proveedor, ID_Empleado, Motivo_General)
VALUES (@DevProvID, (SELECT TOP 1 ID FROM Proveedores), @EmpleadoID, 'Lote con empaques dañados');

INSERT INTO Detalles_Devoluciones_Proveedores (ID_Devolucion, ID_Medicamento, Cantidad, Precio_Unitario, Motivo_Item)
VALUES (@DevProvID, @MedID, 5, 20.00, 'Cajas golpeadas');

-- Ajuste de stock por salida
UPDATE Medicamentos SET Stock = Stock - 5 WHERE ID = @MedID;
```

## Posibles Extensiones Futuras
- Triggers para actualizar stock automáticamente.
- Tabla de auditoría (histórico de precios y movimientos de inventario).
- Gestión de lotes más granular (tabla Lotes con trazabilidad de cada ingreso).
- Estados avanzados de devoluciones (APROBADA_PARCIAL, EN_REVISION).
- Reportes (ventas por período, rotación, próximos a vencer, devoluciones por motivo).
- Control de usuarios y roles (seguridad y permisos de operación).

## Estructura del Repositorio
```
Schema/SchemaDb.sql  - Script principal de creación
diagramas/           - Diagramas (si se agregan)
querys/              - Consultas auxiliares o ejemplos
```

## Licencia
Ver archivo `LICENSE` si se define una licencia específica.

---
Si necesitas un DER (diagrama entidad-relación) o generación de procedimientos almacenados (ej. registrar venta + actualización de stock) puedo ayudarte a generarlos. Solo pídelo.
