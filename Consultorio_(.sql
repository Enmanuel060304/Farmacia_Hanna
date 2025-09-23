CREATE TABLE Pacientes(
    ID_P UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    DNI VARCHAR(50) NOT NULL,
    Fecha_De_Nacimientos DATE NOT NULL,
    Telefono int CHECK(Telefono BETWEEN 0 AND 99999999),
    Direccion VARCHAR (100)
);

CREATE TABLE Expedientes(
    ID_E UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Fecha_Creacion DATE NOT NULL,
    Notas_Generales TEXT,
    ID_pacientes UNIQUEIDENTIFIER
    CONSTRAINT FK_paciente_Expediente FOREIGN KEY (ID_Pacientes) REFERENCES Pacientes(ID_P)  
);


CREATE TABLE Antecedentes(
    ID_Antecedentes UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Tipo VARCHAR(50) NOT NULL,
    Descripcion TEXT, 
    ID_Expediente UNIQUEIDENTIFIER,  
    CONSTRAINT FK_Expediente_Antecedente FOREIGN KEY (ID_Expediente) REFERENCES Expedientes(ID_E)
);

CREATE TABLE Consultas(
    ID_Consultas UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Fecha_Consultas DATE NOT NULL,
    Hora_Consultas TIME NOT NULL,
    Motivo_Consultas TEXT NOT NULL,
    Diagnostico TEXT,
    Tratamiento Text,
    Observaciones Text,
    ID_Empleado UNIQUEIDENTIFIER,
    ID_Expediente UNIQUEIDENTIFIER,
    CONSTRAINT FK_Expediente_Consulta FOREIGN KEY (ID_Expediente) REFERENCES Expedientes(ID_E),
    CONSTRAINT FK_Empleado_Consulta FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID)
);


CREATE TABLE Devoluciones (
    ID_Devolucion INT IDENTITY(1,1) PRIMARY KEY,
    Tipo_Devolucion VARCHAR(20) NOT NULL CHECK (Tipo_Devolucion IN ('Proveedor', 'Cliente', 'Stock')),
    Fecha_Devolucion DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Hora_Devolucion TIME NOT NULL DEFAULT CAST(GETDATE() AS TIME),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente' CHECK (Estado IN ('Pendiente', 'Procesada', 'Cancelada')),
    Motivo VARCHAR(200) NOT NULL,
    Cantidad_Total INT NOT NULL,
    -- Relaciones según el tipo de devolución
    ID_Proveedor INT NULL,
    ID_Cliente INT NULL,
    ID_Venta INT NULL,
    ID_Empleado INT NOT NULL,
    -- Auditoría
    Fecha_Registro DATETIME NOT NULL DEFAULT GETDATE(),
    Usuario_Registro VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
    
    -- Constraints de integridad según el tipo
    CONSTRAINT CHK_Tipo_Devolucion CHECK (
        (Tipo_Devolucion = 'Proveedor' AND ID_Proveedor IS NOT NULL AND ID_Cliente IS NULL) OR
        (Tipo_Devolucion = 'Cliente' AND ID_Cliente IS NOT NULL AND ID_Venta IS NOT NULL AND ID_Proveedor IS NULL) OR
        (Tipo_Devolucion = 'Stock' AND ID_Proveedor IS NULL AND ID_Cliente IS NULL)
    )
);

CREATE TABLE Detalle_Devolucion (
    ID_Detalle_Devolucion INT IDENTITY(1,1) PRIMARY KEY,
    ID_Devolucion INT NOT NULL,
    ID_Medicamento INT NOT NULL,
    Lote VARCHAR(50) NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    Precio_Unitario DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    Motivo_Especifico VARCHAR(200) NULL,
    Accion_Tomar VARCHAR(20) NOT NULL CHECK (Accion_Tomar IN ('ReingresarStock', 'Destruir', 'DevolverProveedor')),
);