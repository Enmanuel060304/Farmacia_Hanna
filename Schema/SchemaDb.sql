CREATE DATABASE Farmacia_Hanna;
USE Farmacia_Hanna;

CREATE TABLE Proveedores (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Nombre VARCHAR(50),
    Contacto VARCHAR(50),
    Telefono VARCHAR(50),
    Direccion VARCHAR(50)
);

CREATE TABLE Categorias (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Nombre VARCHAR(50),
    Descripcion VARCHAR(50) 
);

CREATE TABLE Laboratorios (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Nombre VARCHAR(50)
);

CREATE TABLE Medicamentos (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(50) NOT NULL,
    Precio_Compra DECIMAL(10,2) NOT NULL,
    Precio_Venta DECIMAL(10,2) NOT NULL,
    Precio_Promocion DECIMAL(10,2) NULL,
    Stock INTEGER NOT NULL,
    Fecha_Ingreso DATE DEFAULT GETDATE(),
    Fecha_Vencimiento DATE NOT NULL,
    Fecha_Devolucion DATE,
    ID_Proveedor UNIQUEIDENTIFIER,
    ID_Categoria UNIQUEIDENTIFIER,
    ID_Laboratorios UNIQUEIDENTIFIER,
    CONSTRAINT FK_Proveedor_Medicamento FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID),
    CONSTRAINT FK_Categoria_Medicamento FOREIGN KEY (ID_Categoria) REFERENCES Categorias(ID),
    CONSTRAINT FK_Laboratorios_Medicamento FOREIGN KEY (ID_Laboratorios) REFERENCES Laboratorios(ID)
);

CREATE TABLE Clientes (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Nombre VARCHAR(50), 
    Telefono VARCHAR(50),
    Direccion VARCHAR(250)
);

CREATE TABLE Empleados (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Nombre VARCHAR(64) NOT NULL,
    Cedula VARCHAR(64) NOT NULL,
    Telefono VARCHAR(64) NOT NULL,
    Cargo VARCHAR(64) NOT NULL,
    Usuario VARCHAR(64) NOT NULL,
    Contraseña_Hash VARCHAR(128)
);

CREATE TABLE Ventas (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    ID_Empleado UNIQUEIDENTIFIER NOT NULL,
    ID_Cliente UNIQUEIDENTIFIER NOT NULL,
    Total DECIMAL(10,2) NOT NULL,   
    Fecha DATE DEFAULT GETDATE(),
    CONSTRAINT FK_Ventas_Empleados FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID),
    CONSTRAINT FK_Ventas_Cliente FOREIGN KEY (ID_Cliente) REFERENCES Clientes(ID)
);

CREATE TABLE Detalles_Ventas (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Cantidad INTEGER NOT NULL,
    Precio_Unitario DECIMAL(10, 2) NOT NULL,
    SubTotal DECIMAL(10,2) NOT NULL,
    ID_Venta UNIQUEIDENTIFIER NOT NULL,
    ID_Medicamento UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT FK_Venta_Detalle FOREIGN KEY (ID_Venta) REFERENCES Ventas(ID),
    CONSTRAINT FK_Medicamento_Detalle FOREIGN KEY (ID_Medicamento) REFERENCES Medicamentos(ID) 
);

CREATE TABLE Compras (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    ID_Proveedor UNIQUEIDENTIFIER NOT NULL,
    Total DECIMAL(10,2) NOT NULL,
    Fecha DATE DEFAULT GETDATE(),
    CONSTRAINT FK_Compras_Proveedores FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID)
);

CREATE TABLE Detalles_Compras (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Cantidad INTEGER NOT NULL,
    Precio_Unitario DECIMAL(10, 2) NOT NULL,
    SubTotal DECIMAL(10,2) NOT NULL,
    ID_Compra UNIQUEIDENTIFIER NOT NULL,
    ID_Medicamento UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT FK_Compra_Detalle FOREIGN KEY (ID_Compra) REFERENCES Compras(ID),
    CONSTRAINT FK_Medicamento_Compra FOREIGN KEY (ID_Medicamento) REFERENCES Medicamentos(ID) 
);

-- ================================
-- DEVOLUCIONES DE CLIENTES
-- ================================
CREATE TABLE Devoluciones_Clientes(
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    ID_Venta UNIQUEIDENTIFIER NOT NULL,
    ID_Empleado UNIQUEIDENTIFIER NOT NULL, -- quién registró la devolución
    Fecha DATETIME DEFAULT GETDATE(),
    Motivo_General VARCHAR(250) NULL,
    Estado VARCHAR(32) DEFAULT 'PENDIENTE' CHECK (Estado IN ('PENDIENTE','ACEPTADA','RECHAZADA')),
    CONSTRAINT FK_Devoluciones_Ventas FOREIGN KEY (ID_Venta) REFERENCES Ventas(ID),
    CONSTRAINT FK_Devoluciones_Clientes_Empleado FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID)
);

CREATE TABLE Detalles_Devoluciones_Clientes(
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    ID_Devolucion UNIQUEIDENTIFIER NOT NULL,
    ID_Medicamento UNIQUEIDENTIFIER NOT NULL,
    ID_Detalle_Venta UNIQUEIDENTIFIER NULL, -- vínculo con detalle original
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    Precio_Unitario DECIMAL(10,2) NOT NULL,     
    Motivo_Item VARCHAR(250) NULL,
    Afecta_Stock BIT DEFAULT 1, -- 1 = vuelve a inventario, 0 = destruido
    SubTotal AS (Cantidad * Precio_Unitario) PERSISTED,
    CONSTRAINT FK_DetalleDev_Devolucion FOREIGN KEY (ID_Devolucion) REFERENCES Devoluciones_Clientes(ID),
    CONSTRAINT FK_DetalleDev_Medicamento FOREIGN KEY (ID_Medicamento) REFERENCES Medicamentos(ID),
    CONSTRAINT FK_DetalleDev_DetalleVenta FOREIGN KEY (ID_Detalle_Venta) REFERENCES Detalles_Ventas(ID)
);

-- ================================
-- DEVOLUCIONES A PROVEEDORES
-- ================================
CREATE TABLE Devoluciones_Proveedores (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    ID_Proveedor UNIQUEIDENTIFIER NOT NULL,
    ID_Compra UNIQUEIDENTIFIER NULL,
    ID_Empleado UNIQUEIDENTIFIER NOT NULL, 
    Fecha DATETIME DEFAULT GETDATE(),
    Motivo_General VARCHAR(250) NULL,
    Estado VARCHAR(32) DEFAULT 'PENDIENTE' CHECK (Estado IN ('PENDIENTE', 'ACEPTADA', 'RECHAZADA')),
    CONSTRAINT FK_DevProv_Proveedor FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID),
    CONSTRAINT FK_DevProv_Compra FOREIGN KEY (ID_Compra) REFERENCES Compras(ID),
    CONSTRAINT FK_DevProv_Empleado FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID)
);

CREATE TABLE Detalles_Devoluciones_Proveedores (
    ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    ID_Devolucion UNIQUEIDENTIFIER NOT NULL,
    ID_Medicamento UNIQUEIDENTIFIER NOT NULL,
    ID_Detalle_Compra UNIQUEIDENTIFIER NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    Precio_Unitario DECIMAL(10,2) NOT NULL,     
    Motivo_Item VARCHAR(250) NULL,
    SubTotal AS (Cantidad * Precio_Unitario) PERSISTED,
    CONSTRAINT FK_DetDevProv_Devolucion FOREIGN KEY (ID_Devolucion) REFERENCES Devoluciones_Proveedores(ID),
    CONSTRAINT FK_DetDevProv_Medicamento FOREIGN KEY (ID_Medicamento) REFERENCES Medicamentos(ID),
    CONSTRAINT FK_DetDevProv_DetalleCompra FOREIGN KEY (ID_Detalle_Compra) REFERENCES Detalles_Compras(ID)
);
