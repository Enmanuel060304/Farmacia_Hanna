CREATE DATABASE Farmacia_Hanna;
use Farmacia_Hanna;

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
    Precio_Compra DECIMAL(2,2) NOT NULL,
    Precio_Venta DECIMAL(2,2) NOT NULL,
    Stock INTEGER NOT NULL,
    Fecha_Ingreso DATE DEFAULT GETDATE(),
    Fecha_Vencimiento DATE NOT NULL,
    Fecha_Devolucion DATE,
    ID_Proveedor UNIQUEIDENTIFIER,
    ID_Categoria UNIQUEIDENTIFIER,
    ID_Laboratorios UNIQUEIDENTIFIER,
    CONSTRAINT FK_Proveedor_Medicamento FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID),
    CONSTRAINT FK_Categoria_Medicamento FOREIGN KEY (ID_Categoria) REFERENCES Categorias(ID),
    CONSTRAINT FK_Laboratorios_Medicamento FOREIGN KEY (ID_Laboratorios) REFERENCES Laboratorios(ID),
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
)

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

-- Select * FROM Medicamentos;

-- INSERT INTO Proveedores(Nombre, Contacto, Telefono, Direccion) VALUES ('obed', 'catherine', '12457 caterine llamame', 'cristo rey')

-- INSERTO INTO Medicamentos(Nombre, Descripcion, )

-- SELECT * FROM Proveedores;

-- SELECT Me.Nombre, Me.Descripcion, Lab.Nombre AS 'Nombre Laboratorio', Pro.Nombre as 'Proveedor' FROM Medicamentos AS Me
-- INNER JOIN Proveedores AS Pro
-- ON Me.ID_Proveedor = Pro.ID
-- INNER JOIN Laboratorios AS Lab
-- ON Lab.ID = Me.ID_Laboratorios
-- WHERE Pro.Nombre = 'Farmacéutica S.A.';