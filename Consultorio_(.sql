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
