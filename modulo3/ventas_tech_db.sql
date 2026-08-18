-- =====================================================================
-- ventas_tech_db.sql
-- Checkpoint: Script SQL de Ingeniería de Datos
-- Modelo de Ventas de Tecnología (3NF)
-- Autor: Franco Cabral

IF OBJECT_ID('dbo.Ventas', 'U') IS NOT NULL DROP TABLE dbo.Ventas;
IF OBJECT_ID('dbo.Productos', 'U') IS NOT NULL DROP TABLE dbo.Productos;
IF OBJECT_ID('dbo.Categorias', 'U') IS NOT NULL DROP TABLE dbo.Categorias;
IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL DROP TABLE dbo.Clientes;
GO

-- =====================================================================
-- 1. DEFINICIÓN DEL ESQUEMA (DDL)
-- Orden: primero las tablas de dimensiones, al final la tabla de hechos.
-- =====================================================================

-- ---------------------------------------------------------------
-- Tabla: Categorias
-- Se separa de Productos para cumplir 3NF (evita dependencia
-- transitiva y texto repetido de categoría en cada producto).
-- ---------------------------------------------------------------
CREATE TABLE Categorias (
    CategoriaID     INT             IDENTITY(1,1) NOT NULL,
    NombreCategoria VARCHAR(60)     NOT NULL,
    CONSTRAINT PK_Categorias PRIMARY KEY (CategoriaID),
    CONSTRAINT UQ_Categorias_Nombre UNIQUE (NombreCategoria)
);
GO

-- ---------------------------------------------------------------
-- Tabla: Productos
-- ---------------------------------------------------------------
CREATE TABLE Productos (
    ProductoID   INT             IDENTITY(1,1) NOT NULL,
    Nombre       VARCHAR(120)    NOT NULL,
    Precio       DECIMAL(12,2)   NOT NULL,
    CategoriaID  INT             NOT NULL,
    CONSTRAINT PK_Productos PRIMARY KEY (ProductoID),
    CONSTRAINT FK_Producto_Categoria
        FOREIGN KEY (CategoriaID) REFERENCES Categorias (CategoriaID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT CHK_Precio_Positivo CHECK (Precio >= 0)
);
GO

-- ---------------------------------------------------------------
-- Tabla: Clientes
-- ---------------------------------------------------------------
CREATE TABLE Clientes (
    ClienteID   INT             IDENTITY(1,1) NOT NULL,
    Nombre      VARCHAR(120)    NOT NULL,
    Email       VARCHAR(150)    NOT NULL,
    Ciudad      VARCHAR(80)     NULL,
    CONSTRAINT PK_Clientes PRIMARY KEY (ClienteID),
    CONSTRAINT UQ_Clientes_Email UNIQUE (Email)
);
GO

-- ---------------------------------------------------------------
-- Tabla: Ventas (tabla de hechos)
-- Conecta Clientes y Productos. Se crea al final porque depende
-- de que ambas tablas referenciadas ya existan.
-- ---------------------------------------------------------------
CREATE TABLE Ventas (
    ID_Venta    INT             IDENTITY(1,1) NOT NULL,
    Fecha       DATE            NOT NULL,
    ClienteID   INT             NOT NULL,
    ProductoID  INT             NOT NULL,
    Cantidad    INT             NOT NULL,
    CONSTRAINT PK_Ventas PRIMARY KEY (ID_Venta),
    CONSTRAINT FK_Venta_Cliente
        FOREIGN KEY (ClienteID) REFERENCES Clientes (ClienteID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT FK_Venta_Producto
        FOREIGN KEY (ProductoID) REFERENCES Productos (ProductoID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT CHK_Cantidad_Positiva CHECK (Cantidad > 0)
);
GO

-- =====================================================================
-- 2. CARGA INICIAL DE DATOS (DML)
-- Orden: Categorias -> Productos -> Clientes -> Ventas
-- =====================================================================

-- ---------------------------------------------------------------
-- Categorías (3)
-- ---------------------------------------------------------------
INSERT INTO Categorias (NombreCategoria) VALUES
    ('Notebooks'),
    ('Periféricos'),
    ('Componentes');
GO

-- ---------------------------------------------------------------
-- Productos (5), distribuidos en las categorías anteriores
-- CategoriaID: 1 = Notebooks, 2 = Periféricos, 3 = Componentes
-- ---------------------------------------------------------------
INSERT INTO Productos (Nombre, Precio, CategoriaID) VALUES
    ('Notebook Lenovo IdeaPad 3',      850000.00, 1),
    ('Notebook ASUS Vivobook 15',      920000.00, 1),
    ('Mouse Inalámbrico Logitech M170', 15000.00, 2),
    ('Teclado Mecánico Redragon K552',  45000.00, 2),
    ('Memoria RAM Kingston 8GB DDR4',   28000.00, 3);
GO

-- ---------------------------------------------------------------
-- Clientes (3)
-- ---------------------------------------------------------------
INSERT INTO Clientes (Nombre, Email, Ciudad) VALUES
    ('Martina Gómez',    'martina.gomez@correo.com',  'Río Cuarto'),
    ('Lucas Fernández',  'lucas.fernandez@correo.com','Córdoba'),
    ('Sofía Álvarez',    'sofia.alvarez@correo.com',  'Villa María');
GO

-- ---------------------------------------------------------------
-- Ventas (10 transacciones)
-- ClienteID: 1=Martina, 2=Lucas, 3=Sofía
-- ProductoID: 1=Notebook Lenovo, 2=Notebook ASUS, 3=Mouse,
--             4=Teclado, 5=Memoria RAM
-- ---------------------------------------------------------------
INSERT INTO Ventas (Fecha, ClienteID, ProductoID, Cantidad) VALUES
    ('2026-01-05', 1, 1, 1),
    ('2026-01-07', 2, 3, 2),
    ('2026-01-10', 3, 5, 1),
    ('2026-01-15', 1, 4, 1),
    ('2026-01-18', 2, 2, 1),
    ('2026-01-22', 3, 3, 1),
    ('2026-02-01', 1, 5, 2),
    ('2026-02-04', 2, 4, 1),
    ('2026-02-09', 3, 1, 1),
    ('2026-02-14', 1, 3, 3);
GO
