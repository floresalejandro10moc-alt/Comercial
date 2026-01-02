-- ==============================================================================
-- SCRIPT FINAL INTEGRADO: SISTEMA DE VENTAS SDV
-- FECHA: DICIEMBRE 2025
-- MOTOR: MySQL / MariaDB
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS SistemaVentasSDV;
USE SistemaVentasSDV;

-- Desactivar verificación de llaves foráneas para permitir limpieza total
SET FOREIGN_KEY_CHECKS = 0;

-- 1. LIMPIEZA DE TABLAS (Orden inverso para evitar bloqueos si el check estuviera activo)
-- 1. LIMPIEZA DE TABLAS (Nombres corregidos según los CREATE TABLE)
DROP TABLE IF EXISTS CUENTASXASIENTO; -- Corregido: antes era CTAxASI
DROP TABLE IF EXISTS ASIENTOS;
DROP TABLE IF EXISTS PROxOC; 
DROP TABLE IF EXISTS PROxREC; 
DROP TABLE IF EXISTS PROxFAC; 
DROP TABLE IF EXISTS PROxENT; 
DROP TABLE IF EXISTS PROxAJU;
DROP TABLE IF EXISTS COMPRAS; 
DROP TABLE IF EXISTS RECEPCIONES; 
DROP TABLE IF EXISTS FACTURAS; 
DROP TABLE IF EXISTS ENTREGAS; 
DROP TABLE IF EXISTS AJUSTES;
DROP TABLE IF EXISTS BonxEmpxPag;     -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS DesxEmpxPag;     -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS PagxEmp;         -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS USUARIOS; 
DROP TABLE IF EXISTS Cargas;          -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS Empleados;       -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS PRODUCTOS; 
DROP TABLE IF EXISTS CLIENTES; 
DROP TABLE IF EXISTS PROVEEDORES;
DROP TABLE IF EXISTS CUENTAS; 
DROP TABLE IF EXISTS CATEGORIA_CUENTA; -- Corregido: antes era TIPO_CUENTA
DROP TABLE IF EXISTS Pagos;           -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS Bonificaciones;  -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS Descuentos;      -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS Roles;           -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS Departamentos;   -- Corregido: Coincide mayúsculas/minúsculas
DROP TABLE IF EXISTS UNIDADES_MEDIDAS; 
DROP TABLE IF EXISTS CIUDADES;
DROP TABLE IF EXISTS AUDITORIA_LOG; 
DELIMITER ;

-- Limpiar triggers de CUENTAS
DROP TRIGGER IF EXISTS trg_log_cuentas_ins;
DROP TRIGGER IF EXISTS trg_log_cuentas_upd;
DROP TRIGGER IF EXISTS trg_log_cuentas_del;

-- Limpiar triggers de PROVEEDORES
DROP TRIGGER IF EXISTS trg_log_proveedores_ins;
DROP TRIGGER IF EXISTS trg_log_proveedores_upd;
DROP TRIGGER IF EXISTS trg_log_proveedores_del;

-- Limpiar triggers de CLIENTES
DROP TRIGGER IF EXISTS trg_log_clientes_ins;
DROP TRIGGER IF EXISTS trg_log_clientes_upd;
DROP TRIGGER IF EXISTS trg_log_clientes_del;

-- Limpiar triggers de PRODUCTOS
DROP TRIGGER IF EXISTS trg_log_productos_ins;
DROP TRIGGER IF EXISTS trg_log_productos_upd;
DROP TRIGGER IF EXISTS trg_log_productos_del;

-- Limpiar triggers de EMPLEADOS
DROP TRIGGER IF EXISTS trg_log_empleados_ins;
DROP TRIGGER IF EXISTS trg_log_empleados_upd;
DROP TRIGGER IF EXISTS trg_log_empleados_del;

-- ==============================================================================
-- 2. DDL: CREACIÓN DE ESTRUCTURA DE TABLAS
-- ==============================================================================
CREATE TABLE AUDITORIA_LOG (
    id_log BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    usuario_db VARCHAR(100) NOT NULL,       -- Usuario MySQL
    usuario_sistema VARCHAR(50) NULL,       -- Usuario real del sistema
    host_origen VARCHAR(100) NULL,          -- IP o servidor origen
    aplicacion VARCHAR(50) NULL,            -- web, api, móvil, etc.

    tabla_afectada VARCHAR(50) NOT NULL,
    accion VARCHAR(10) NOT NULL,            -- INSERT, UPDATE, DELETE
    accion_detallada VARCHAR(50) NULL,      -- update_precio, login, etc.

    id_registro VARCHAR(50) NOT NULL,       -- PK del registro afectado
    id_transaccion VARCHAR(100) NULL,       -- Agrupador de eventos

    datos_anteriores JSON,                  -- Estado previo
    datos_nuevos JSON,                      -- Estado posterior
    query_sql TEXT NULL,                    -- SQL ejecutado
    nivel VARCHAR(20) DEFAULT 'INFO',       -- INFO, WARNING, CRITICAL
    comentario TEXT NULL,                   -- Extra contexto

    INDEX idx_tabla_accion (tabla_afectada, accion),
    INDEX idx_fecha (fecha_hora),
    INDEX idx_usuario (usuario_sistema)
);

CREATE TABLE CIUDADES (
    id_Ciudad CHAR(3) NOT NULL,
    ciu_descripcion VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_Ciudad)
);

CREATE TABLE UNIDADES_MEDIDAS (
    id_Unidad_Medida CHAR(3) NOT NULL,
    um_Descripcion VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_Unidad_Medida)
);

CREATE TABLE CATEGORIA_CUENTA (
    ID_TIPOCUENTA CHAR(3) NOT NULL PRIMARY KEY,
    CAT_DESCRIPCION VARCHAR(60) NOT NULL
);

CREATE TABLE Departamentos (
    id_Departamento CHAR(7) NOT NULL,
    dep_Nombre CHAR(30) NOT NULL,
    dep_Telefono CHAR(12),
    dep_Mail CHAR(60),
    ESTADO_DEP CHAR(3),
    PRIMARY KEY (id_Departamento)
);

-- Tabla ROLES
CREATE TABLE Roles (
    id_Rol CHAR(7) NOT NULL,
    rol_Descripcion CHAR(40) NOT NULL,
    ESTADO_ROL CHAR(3),
    PRIMARY KEY (id_Rol)
);

CREATE TABLE Bonificaciones (
    id_Bonificacion CHAR(7) NOT NULL,
    bon_Descripcion CHAR(40) NOT NULL,
    bon_Valor DECIMAL(7, 2),
    ESTADO_BON CHAR(3),
    PRIMARY KEY (id_Bonificacion)
);

CREATE TABLE Descuentos (
    id_Descuento CHAR(7) NOT NULL,
    des_Descripcion CHAR(40) NOT NULL,
    des_Valor DECIMAL(7, 2),
    ESTADO_DES CHAR(3),
    PRIMARY KEY (id_Descuento)
);

CREATE TABLE Pagos (
    id_Pago CHAR(7) NOT NULL,
    pag_Descripcion CHAR(40),
    pag_Fecha_Inicio DATE,
    pag_Fecha_Fin DATE,
    ESTADO_PAG CHAR(3),
    PRIMARY KEY (id_Pago)
);

-- --- ENTIDADES PRINCIPALES ---

CREATE TABLE PROVEEDORES (
    id_Proveedor CHAR(7) NOT NULL,
    prv_Nombre VARCHAR(40) NOT NULL,
    prv_RUC_CED VARCHAR(13) NOT NULL,
    prv_Telefono VARCHAR(10),
    prv_Mail VARCHAR(60),
    id_Ciudad CHAR(3) NOT NULL,
    prv_Celular VARCHAR(10),
    prv_Direccion VARCHAR(60),
    ESTADO_PRV CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Proveedor),
    FOREIGN KEY (id_Ciudad) REFERENCES CIUDADES(id_Ciudad)
);

CREATE TABLE CLIENTES (
    id_Cliente CHAR(7) NOT NULL,
    cli_Nombre VARCHAR(40) NOT NULL,
    cli_RUC_CED VARCHAR(13) NOT NULL,
    cli_Telefono VARCHAR(10),
    cli_Mail VARCHAR(60),
    id_Ciudad CHAR(3) NOT NULL,
    cli_Celular VARCHAR(10),
    cli_Direccion VARCHAR(60),
    ESTADO_CLI CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Cliente),
    FOREIGN KEY (id_Ciudad) REFERENCES CIUDADES(id_Ciudad)
);

CREATE TABLE PRODUCTOS (
    id_Producto CHAR(7) NOT NULL,
    pro_Descripcion VARCHAR(40) NOT NULL,
    pro_UM_Compra CHAR(3) NOT NULL,
    pro_UM_Venta CHAR(3) NOT NULL,
    pro_Valor_Compra DECIMAL(9,2) NOT NULL,
    pro_Precio_Venta DECIMAL(9,2) NOT NULL,
    pro_Saldo_Inicial INT DEFAULT 0,
    pro_Qty_Ingresos INT DEFAULT 0,
    pro_Qty_Egresos INT DEFAULT 0,
    pro_Qty_Ajustes INT DEFAULT 0,
    pro_Saldo_Final INT DEFAULT 0,
    ESTADO_PROD CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Producto),
    FOREIGN KEY (pro_UM_Compra) REFERENCES UNIDADES_MEDIDAS(id_Unidad_Medida),
    FOREIGN KEY (pro_UM_Venta) REFERENCES UNIDADES_MEDIDAS(id_Unidad_Medida)
);

CREATE TABLE Empleados (
    -- Para ser AUTO_INCREMENT, debe ser INT (entero), no CHAR.
    id_Empleado INT AUTO_INCREMENT NOT NULL, 
    
    -- Validación de longitud y prefijo provincial (01-24) en el CONSTRAINT abajo
    emp_Cedula CHAR(10) NOT NULL, 
    
    emp_Apellido1 CHAR(30) NOT NULL,
    emp_Apellido2 CHAR(30),
    emp_Nombre1 CHAR(30) NOT NULL,
    emp_Nombre2 CHAR(30), 
    emp_Sexo CHAR(1),
    -- La validación de edad se hace mejor con Triggers
    emp_FechaNacimiento DATE, 
    -- Validación de positivos en el CONSTRAINT abajo--
    emp_Sueldo DECIMAL(7, 2), 
    
    emp_Mail CHAR(40),
    ESTADO_EMP CHAR(3) DEFAULT 'ACT',
    
    -- Relaciones
    id_Departamento CHAR(7),
    id_Rol CHAR(7),
    
    -- DEFINICIÓN DE LLAVES
    PRIMARY KEY (id_Empleado),
    UNIQUE (emp_Cedula),
    
    -- LLAVES FORÁNEAS
    CONSTRAINT FK_Emp_Dep FOREIGN KEY (id_Departamento) REFERENCES Departamentos(id_Departamento),
    CONSTRAINT FK_Emp_Rol FOREIGN KEY (id_Rol) REFERENCES Roles(id_Rol),
    
    
    -- Sexo solo M o F y Estado solo ACT o INA
    CONSTRAINT CHK_Emp_Sexo CHECK (emp_Sexo IN ('M', 'F')),
    CONSTRAINT CHK_Emp_Estado CHECK (ESTADO_EMP IN ('ACT', 'INA')),

    -- Sueldo Positivo
    CONSTRAINT CHK_Sueldo_Positivo CHECK (emp_Sueldo > 0),

    -- Validación de Cédula:
    --    LENGTH: Que mida exactamente 10 caracteres.
    --    LEFT entre 01 y 24: Que los dos primeros dígitos sean provincia válida.
    CONSTRAINT CHK_Cedula_Valida CHECK (
        CHAR_LENGTH(emp_Cedula) = 10 
        AND LEFT(emp_Cedula, 2) BETWEEN '01' AND '24'
    )
);

-- Tabla USUARIOS (Texto plano para pruebas, según solicitud)
CREATE TABLE USUARIOS (
    id_Usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_Empleado INT NOT NULL,
    id_Rol CHAR(7) NOT NULL,
    usr_Login VARCHAR(50) NOT NULL UNIQUE,
    usr_Password VARCHAR(255) NOT NULL, 
    ESTADO_USR CHAR(3) DEFAULT 'ACT',
    FOREIGN KEY (id_Empleado) REFERENCES EMPLEADOS(id_Empleado),
    FOREIGN KEY (id_Rol) REFERENCES ROLES(id_Rol)
);

CREATE TABLE CUENTAS (
    ID_CODIGOCUENTA VARCHAR(15) NOT NULL PRIMARY KEY,
    ID_TIPOCUENTA CHAR(3) NOT NULL,
    CUE_NOMBRECUENTA VARCHAR(150) NOT NULL,
    CUE_DESCRIPCION VARCHAR(150),
    CUE_TIPOCUENTA CHAR(3) NOT NULL, 
    
    -- Saldos al DEBE (Validados para no ser negativos)
    CUE_DEB00 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB00 >= 0),
    CUE_DEB01 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB01 >= 0),
    CUE_DEB02 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB02 >= 0),
    CUE_DEB03 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB03 >= 0),
    CUE_DEB04 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB04 >= 0),
    CUE_DEB05 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB05 >= 0),
    CUE_DEB06 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB06 >= 0),
    CUE_DEB07 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB07 >= 0),
    CUE_DEB08 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB08 >= 0),
    CUE_DEB09 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB09 >= 0),
    CUE_DEB10 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB10 >= 0),
    CUE_DEB11 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB11 >= 0),
    CUE_DEB12 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB12 >= 0),
    CUE_DEB13 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_DEB13 >= 0),

    -- Saldos al HABER (Validados para no ser negativos)
    CUE_HAB00 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB00 >= 0),
    CUE_HAB01 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB01 >= 0),
    CUE_HAB02 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB02 >= 0),
    CUE_HAB03 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB03 >= 0),
    CUE_HAB04 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB04 >= 0),
    CUE_HAB05 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB05 >= 0),
    CUE_HAB06 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB06 >= 0),
    CUE_HAB07 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB07 >= 0),
    CUE_HAB08 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB08 >= 0),
    CUE_HAB09 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB09 >= 0),
    CUE_HAB10 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB10 >= 0),
    CUE_HAB11 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB11 >= 0),
    CUE_HAB12 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB12 >= 0),
    CUE_HAB13 DECIMAL(15,2) DEFAULT 0 NOT NULL CHECK (CUE_HAB13 >= 0),

    CUE_USERID VARCHAR(20), -- En una futura iteración vincularemos esto a una tabla de Usuarios
    CUE_ESTADOCUENTA CHAR(3) DEFAULT 'ACT' NOT NULL,

    CONSTRAINT FK_CUENTAS_TIPO FOREIGN KEY (ID_TIPOCUENTA) 
        REFERENCES CATEGORIA_CUENTA(ID_TIPOCUENTA),

    -- VALIDACIONES "ANTI-USUARIO"
    -- 1. Tipo de cuenta solo permite Mayor (MAY) o Detalle (DET)
    CONSTRAINT CK_CUE_TIPO CHECK (CUE_TIPOCUENTA IN ('MAY', 'DET')),
    -- 2. Estado solo permite Activo (ACT) o Inactivo (INA)
    CONSTRAINT CK_CUE_ESTADO CHECK (CUE_ESTADOCUENTA IN ('ACT', 'INA'))
);

-- --- TRANSACCIONES CABECERAS ---

CREATE TABLE COMPRAS (
    id_Compra CHAR(7) NOT NULL,
    id_Proveedor CHAR(7) NOT NULL,
    oc_Fecha_Hora DATETIME NOT NULL,
    oc_Subtotal DECIMAL(9,2) DEFAULT 0,
    oc_IVA INT DEFAULT 0,
    ESTADO_OC CHAR(3) DEFAULT 'PEN',
    PRIMARY KEY (id_Compra),
    FOREIGN KEY (id_Proveedor) REFERENCES PROVEEDORES(id_Proveedor)
);

CREATE TABLE RECEPCIONES (
    id_Recibo CHAR(7) NOT NULL,
    USER_ID CHAR(12),
    rec_Descripcion VARCHAR(30),
    rec_FechaHora DATETIME NOT NULL,
    rec_Num_Produc INT DEFAULT 0,
    ESTADO_REC CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Recibo)
);

CREATE TABLE FACTURAS (
    id_Factura CHAR(7) NOT NULL,
    id_Cliente CHAR(7) NOT NULL,
    fac_Fecha_Hora DATETIME NOT NULL,
    fac_Subtotal DECIMAL(9,2) DEFAULT 0,
    fac_IVA INT DEFAULT 0,
    ESTADO_FAC CHAR(3) DEFAULT 'PEN',
    PRIMARY KEY (id_Factura),
    FOREIGN KEY (id_Cliente) REFERENCES CLIENTES(id_Cliente)
);

CREATE TABLE ENTREGAS (
    id_Entrega CHAR(7) NOT NULL,
    USER_ID CHAR(12),
    ent_Descripcion VARCHAR(30),
    ent_FechaHora DATETIME NOT NULL,
    ent_Num_Produc INT DEFAULT 0,
    ESTADO_ENT CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Entrega)
);

CREATE TABLE AJUSTES (
    id_Ajuste CHAR(7) NOT NULL,
    USER_ID CHAR(12),
    aju_Descripcion VARCHAR(30),
    aju_FechaHora DATETIME NOT NULL,
    aju_Num_Produc INT DEFAULT 0,
    ESTADO_AJU CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Ajuste)
);

CREATE TABLE ASIENTOS (
    ID_ASIENTOCONTABLE VARCHAR(20) NOT NULL PRIMARY KEY,
    ASI_FECHAHORA DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ASI_DESCRIPCION VARCHAR(200) NOT NULL, 
    ASI_ESTADOASIENTO CHAR(3) DEFAULT 'BOR' NOT NULL, 
    ASI_TOTAL_DEBE DECIMAL(15,2) DEFAULT 0 NOT NULL,
    ASI_TOTAL_HABER DECIMAL(15,2) DEFAULT 0 NOT NULL,
    ASI_USERID VARCHAR(20),

    -- Validaciones Previas
    CONSTRAINT CK_ASI_ESTADO CHECK (ASI_ESTADOASIENTO IN ('BOR', 'CON', 'APR', 'ACT', 'ANU')),
    CONSTRAINT CK_ASI_POSITIVOS CHECK (ASI_TOTAL_DEBE >= 0 AND ASI_TOTAL_HABER >= 0)
);

CREATE TABLE Cargas (
    id_Carga CHAR(7) NOT NULL,
    car_Cedula CHAR(10),
    car_Apellido1 CHAR(30) NOT NULL,
    car_Apellido2 CHAR(30),
    car_Nombre1 CHAR(30) NOT NULL,
    car_Nombre2 CHAR(30),
    car_Sexo CHAR(1),
    car_FechaNacimiento DATE,
    ESTADO_CAR CHAR(3),
    id_Empleado INT NOT NULL,
    PRIMARY KEY (id_Carga),
    UNIQUE (car_Cedula),
    CONSTRAINT FK_Carga_Emp FOREIGN KEY (id_Empleado) REFERENCES Empleados(id_Empleado)
);

-- --- DETALLES ---

CREATE TABLE PROxOC (
    id_Compra CHAR(7) NOT NULL,
    id_Producto CHAR(7) NOT NULL,
    pxo_Cantidad INT NOT NULL,
    pxo_Valor DECIMAL(9,2) NOT NULL,
    ESTADO_PxOC CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Compra, id_Producto),
    FOREIGN KEY (id_Compra) REFERENCES COMPRAS(id_Compra),
    FOREIGN KEY (id_Producto) REFERENCES PRODUCTOS(id_Producto)
);

CREATE TABLE PROxREC (
    id_Recibo CHAR(7) NOT NULL,
    id_Producto CHAR(7) NOT NULL,
    pxr_Cantidad INT NOT NULL,
    pxr_Qty_Recibida INT NOT NULL,
    ESTADO_PxR CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Recibo, id_Producto),
    FOREIGN KEY (id_Recibo) REFERENCES RECEPCIONES(id_Recibo),
    FOREIGN KEY (id_Producto) REFERENCES PRODUCTOS(id_Producto)
);

CREATE TABLE PROxFAC (
    id_Factura CHAR(7) NOT NULL,
    id_Producto CHAR(7) NOT NULL,
    pxf_Cantidad INT NOT NULL,
    pxf_Valor DECIMAL(9,2) NOT NULL,
    ESTADO_PxF CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Factura, id_Producto),
    FOREIGN KEY (id_Factura) REFERENCES FACTURAS(id_Factura),
    FOREIGN KEY (id_Producto) REFERENCES PRODUCTOS(id_Producto)
);

CREATE TABLE PROxENT (
    id_Entrega CHAR(7) NOT NULL,
    id_Producto CHAR(7) NOT NULL,
    pxe_Cantidad INT NOT NULL,
    pxe_Qty_Entregada INT NOT NULL,
    ESTADO_PxE CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Entrega, id_Producto),
    FOREIGN KEY (id_Entrega) REFERENCES ENTREGAS(id_Entrega),
    FOREIGN KEY (id_Producto) REFERENCES PRODUCTOS(id_Producto)
);

CREATE TABLE PROxAJU (
    id_Ajuste CHAR(7) NOT NULL,
    id_Producto CHAR(7) NOT NULL,
    pxa_Cantidad INT DEFAULT 0,
    pxa_Qty_Ajustada INT DEFAULT 0,
    ESTADO_PxA CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (id_Ajuste, id_Producto),
    FOREIGN KEY (id_Ajuste) REFERENCES AJUSTES(id_Ajuste),
    FOREIGN KEY (id_Producto) REFERENCES PRODUCTOS(id_Producto)
);

CREATE TABLE CUENTASXASIENTO (
    ID_CXA INT AUTO_INCREMENT PRIMARY KEY,
    ID_ASIENTOCONTABLE VARCHAR(20) NOT NULL,
    ID_CODIGOCUENTA VARCHAR(15) NOT NULL,
    CXA_MONTODEBE DECIMAL(15,2) DEFAULT 0 NOT NULL,
    CXA_MONTOHABER DECIMAL(15,2) DEFAULT 0 NOT NULL,
    CXA_DESCRIPCION VARCHAR(200),
    CXA_ESTADOCXA CHAR(3) DEFAULT 'VAL' NOT NULL, 

    CONSTRAINT FK_CXA_ASIENTO FOREIGN KEY (ID_ASIENTOCONTABLE) 
        REFERENCES ASIENTOS(ID_ASIENTOCONTABLE),
        
    -- --> MEJORA EN FK: Evitar borrar una cuenta si ya tiene movimientos
    CONSTRAINT FK_CXA_CUENTA FOREIGN KEY (ID_CODIGOCUENTA) 
        REFERENCES CUENTAS(ID_CODIGOCUENTA)
        ON DELETE NO ACTION, -- Esto es el default, pero lo hago explícito

    -- Validaciones Previas
    CONSTRAINT CK_CXA_POSITIVOS CHECK (CXA_MONTODEBE >= 0 AND CXA_MONTOHABER >= 0),
    CONSTRAINT CK_CXA_ESTADO CHECK (CXA_ESTADOCXA IN ('VAL', 'ELI')),
    CONSTRAINT CK_CXA_EXCLUSIVO CHECK (
        (CXA_MONTODEBE > 0 AND CXA_MONTOHABER = 0) 
        OR 
        (CXA_MONTODEBE = 0 AND CXA_MONTOHABER > 0)
    )
);

CREATE TABLE PagxEmp (
    id_Pago CHAR(7) NOT NULL,
    id_Empleado INT NOT NULL,
    emp_Sueldo DECIMAL(7, 2),
    emp_Bonificaciones DECIMAL(7, 2),
    emp_Descuentos DECIMAL(7, 2),
    emp_Valor_Neto DECIMAL(7, 2),
    ESTADO_PxE CHAR(3),
    PRIMARY KEY (id_Pago, id_Empleado),
    CONSTRAINT FK_PxE_Pago FOREIGN KEY (id_Pago) REFERENCES Pagos(id_Pago),
    CONSTRAINT FK_PxE_Emp FOREIGN KEY (id_Empleado) REFERENCES Empleados(id_Empleado)
);

CREATE TABLE BonxEmpxPag (
    id_Bonificacion CHAR(7) NOT NULL,
    id_Empleado INT NOT NULL,
    id_Pago CHAR(7) NOT NULL,
    bxe_Fecha DATE,
    bxe_Valor DECIMAL(7, 2),
    ESTADO_BXE CHAR(3),
    PRIMARY KEY (id_Bonificacion, id_Empleado, id_Pago),
    CONSTRAINT FK_BxE_Bon FOREIGN KEY (id_Bonificacion) REFERENCES Bonificaciones(id_Bonificacion),
    CONSTRAINT FK_BxE_Emp FOREIGN KEY (id_Empleado) REFERENCES Empleados(id_Empleado),
    CONSTRAINT FK_BxE_Pago FOREIGN KEY (id_Pago) REFERENCES Pagos(id_Pago)
);

CREATE TABLE DesxEmpxPag (
    id_Descuento CHAR(7) NOT NULL,
    id_Empleado INT NOT NULL,
    id_Pago CHAR(7) NOT NULL,
    dxe_Fecha DATE,
    dxe_Valor DECIMAL(7, 2),
    ESTADO_DXE CHAR(3),
    PRIMARY KEY (id_Descuento, id_Empleado, id_Pago),
    CONSTRAINT FK_DxE_Des FOREIGN KEY (id_Descuento) REFERENCES Descuentos(id_Descuento),
    CONSTRAINT FK_DxE_Emp FOREIGN KEY (id_Empleado) REFERENCES Empleados(id_Empleado),
    CONSTRAINT FK_DxE_Pago FOREIGN KEY (id_Pago) REFERENCES Pagos(id_Pago)
);

DELIMITER //

-- 1. INSERT CUENTAS
CREATE TRIGGER trg_log_cuentas_ins
AFTER INSERT ON CUENTAS
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion, 
        tabla_afectada, accion, accion_detallada, id_registro, 
        datos_nuevos, nivel
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'CUENTAS', 'INSERT', 'Creación de Cuenta Contable', NEW.ID_CODIGOCUENTA,
        JSON_OBJECT('nombre', NEW.CUE_NOMBRECUENTA, 'tipo', NEW.CUE_TIPOCUENTA, 'saldo_deb', NEW.CUE_DEB00, 'saldo_hab', NEW.CUE_HAB00),
        'INFO'
    );
END//

-- 2. UPDATE CUENTAS
CREATE TRIGGER trg_log_cuentas_upd
AFTER UPDATE ON CUENTAS
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, accion_detallada, id_registro,
        datos_anteriores, datos_nuevos, nivel
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'CUENTAS', 'UPDATE', 'Modificación de Cuenta', OLD.ID_CODIGOCUENTA,
        JSON_OBJECT('nombre', OLD.CUE_NOMBRECUENTA, 'estado', OLD.CUE_ESTADOCUENTA, 'saldo_deb', OLD.CUE_DEB00),
        JSON_OBJECT('nombre', NEW.CUE_NOMBRECUENTA, 'estado', NEW.CUE_ESTADOCUENTA, 'saldo_deb', NEW.CUE_DEB00),
        'INFO'
    );
END//

-- 3. DELETE CUENTAS
CREATE TRIGGER trg_log_cuentas_del
BEFORE DELETE ON CUENTAS
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, accion_detallada, id_registro,
        datos_anteriores, nivel
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'CUENTAS', 'DELETE', 'Eliminación de Cuenta', OLD.ID_CODIGOCUENTA,
        JSON_OBJECT('nombre', OLD.CUE_NOMBRECUENTA, 'descripcion', OLD.CUE_DESCRIPCION),
        'WARNING'
    );
END//

-- 1. INSERT PROVEEDORES
CREATE TRIGGER trg_log_proveedores_ins
AFTER INSERT ON PROVEEDORES
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, accion_detallada, id_registro,
        datos_nuevos
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'PROVEEDORES', 'INSERT', 'Nuevo Proveedor', NEW.id_Proveedor,
        JSON_OBJECT('nombre', NEW.prv_Nombre, 'ruc', NEW.prv_RUC_CED, 'ciudad', NEW.id_Ciudad)
    );
END//

-- 2. UPDATE PROVEEDORES
CREATE TRIGGER trg_log_proveedores_upd
AFTER UPDATE ON PROVEEDORES
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, id_registro,
        datos_anteriores, datos_nuevos
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'PROVEEDORES', 'UPDATE', OLD.id_Proveedor,
        JSON_OBJECT('nombre', OLD.prv_Nombre, 'telefono', OLD.prv_Telefono, 'estado', OLD.ESTADO_PRV),
        JSON_OBJECT('nombre', NEW.prv_Nombre, 'telefono', NEW.prv_Telefono, 'estado', NEW.ESTADO_PRV)
    );
END//

-- 3. DELETE PROVEEDORES
CREATE TRIGGER trg_log_proveedores_del
BEFORE DELETE ON PROVEEDORES
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, id_registro, datos_anteriores, nivel
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'PROVEEDORES', 'DELETE', OLD.id_Proveedor,
        JSON_OBJECT('nombre', OLD.prv_Nombre, 'ruc', OLD.prv_RUC_CED),
        'WARNING'
    );
END//

-- 1. INSERT CLIENTES
CREATE TRIGGER trg_log_clientes_ins
AFTER INSERT ON CLIENTES
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, id_registro, datos_nuevos
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'CLIENTES', 'INSERT', NEW.id_Cliente,
        JSON_OBJECT('nombre', NEW.cli_Nombre, 'ruc', NEW.cli_RUC_CED, 'mail', NEW.cli_Mail)
    );
END//

-- 2. UPDATE CLIENTES
CREATE TRIGGER trg_log_clientes_upd
AFTER UPDATE ON CLIENTES
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, id_registro,
        datos_anteriores, datos_nuevos
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'CLIENTES', 'UPDATE', OLD.id_Cliente,
        JSON_OBJECT('nombre', OLD.cli_Nombre, 'direccion', OLD.cli_Direccion, 'estado', OLD.ESTADO_CLI),
        JSON_OBJECT('nombre', NEW.cli_Nombre, 'direccion', NEW.cli_Direccion, 'estado', NEW.ESTADO_CLI)
    );
END//

-- 3. DELETE CLIENTES
CREATE TRIGGER trg_log_clientes_del
BEFORE DELETE ON CLIENTES
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, id_registro, datos_anteriores, nivel
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'CLIENTES', 'DELETE', OLD.id_Cliente,
        JSON_OBJECT('nombre', OLD.cli_Nombre, 'ruc', OLD.cli_RUC_CED),
        'WARNING'
    );
END//

-- 1. INSERT PRODUCTOS
CREATE TRIGGER trg_log_productos_ins
AFTER INSERT ON PRODUCTOS
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, accion_detallada, id_registro, datos_nuevos
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'PRODUCTOS', 'INSERT', 'Alta de Producto', NEW.id_Producto,
        JSON_OBJECT('desc', NEW.pro_Descripcion, 'costo', NEW.pro_Valor_Compra, 'precio', NEW.pro_Precio_Venta, 'stock', NEW.pro_Saldo_Final)
    );
END//

-- 2. UPDATE PRODUCTOS (Detecta cambios críticos)
CREATE TRIGGER trg_log_productos_upd
AFTER UPDATE ON PRODUCTOS
FOR EACH ROW
BEGIN
    DECLARE v_nivel VARCHAR(20) DEFAULT 'INFO';
    DECLARE v_comentario TEXT DEFAULT NULL;

    -- Si el precio cambia drásticamente o el stock llega a 0, elevamos el nivel
    IF NEW.pro_Saldo_Final = 0 AND OLD.pro_Saldo_Final > 0 THEN
        SET v_nivel = 'WARNING';
        SET v_comentario = 'El stock ha llegado a cero.';
    END IF;

    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, accion_detallada, id_registro,
        datos_anteriores, datos_nuevos, nivel, comentario
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'PRODUCTOS', 'UPDATE', 'Cambio Inventario/Precio', OLD.id_Producto,
        JSON_OBJECT('precio', OLD.pro_Precio_Venta, 'stock', OLD.pro_Saldo_Final, 'estado', OLD.ESTADO_PROD),
        JSON_OBJECT('precio', NEW.pro_Precio_Venta, 'stock', NEW.pro_Saldo_Final, 'estado', NEW.ESTADO_PROD),
        v_nivel, v_comentario
    );
END//

-- 3. DELETE PRODUCTOS
CREATE TRIGGER trg_log_productos_del
BEFORE DELETE ON PRODUCTOS
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, id_registro, datos_anteriores, nivel
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'PRODUCTOS', 'DELETE', OLD.id_Producto,
        JSON_OBJECT('desc', OLD.pro_Descripcion, 'stock_final', OLD.pro_Saldo_Final),
        'CRITICAL' -- Borrar productos es una acción sensible
    );
END//

-- 1. INSERT EMPLEADOS
CREATE TRIGGER trg_log_empleados_ins
AFTER INSERT ON Empleados
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, accion_detallada, id_registro, datos_nuevos
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'EMPLEADOS', 'INSERT', 'Contratación', CAST(NEW.id_Empleado AS CHAR),
        JSON_OBJECT('cedula', NEW.emp_Cedula, 'nombre', CONCAT(NEW.emp_Nombre1, ' ', NEW.emp_Apellido1), 'sueldo', NEW.emp_Sueldo, 'rol', NEW.id_Rol)
    );
END//

-- 2. UPDATE EMPLEADOS
CREATE TRIGGER trg_log_empleados_upd
AFTER UPDATE ON Empleados
FOR EACH ROW
BEGIN
    DECLARE v_accion_det VARCHAR(50) DEFAULT 'Actualización Datos';
    
    -- Detectar si es un cambio de sueldo
    IF OLD.emp_Sueldo <> NEW.emp_Sueldo THEN
        SET v_accion_det = 'Cambio Salarial';
    END IF;

    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, accion_detallada, id_registro,
        datos_anteriores, datos_nuevos
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'EMPLEADOS', 'UPDATE', v_accion_det, CAST(OLD.id_Empleado AS CHAR),
        JSON_OBJECT('sueldo', OLD.emp_Sueldo, 'rol', OLD.id_Rol, 'depto', OLD.id_Departamento, 'estado', OLD.ESTADO_EMP),
        JSON_OBJECT('sueldo', NEW.emp_Sueldo, 'rol', NEW.id_Rol, 'depto', NEW.id_Departamento, 'estado', NEW.ESTADO_EMP)
    );
END//

-- 3. DELETE EMPLEADOS
CREATE TRIGGER trg_log_empleados_del
BEFORE DELETE ON Empleados
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_LOG (
        usuario_db, usuario_sistema, host_origen, aplicacion,
        tabla_afectada, accion, id_registro, datos_anteriores, nivel
    ) VALUES (
        USER(), @app_user, @@hostname, 'SistemaVentasSDV',
        'EMPLEADOS', 'DELETE', CAST(OLD.id_Empleado AS CHAR),
        JSON_OBJECT('cedula', OLD.emp_Cedula, 'nombre_completo', CONCAT(OLD.emp_Nombre1, ' ', OLD.emp_Apellido1)),
        'CRITICAL'
    );
END//

DELIMITER ;
-- ==============================================================================
-- 3. DML: POBLADO DE DATOS (MÁSTER)
-- ==============================================================================

-- 3.1 TABLAS MAESTRAS
INSERT INTO CIUDADES (id_Ciudad, ciu_descripcion) VALUES 
('UIO', 'QUITO'), ('GYE', 'GUAYAQUIL'), ('CUE', 'CUENCA'), ('MNT', 'MANTA'), ('LOJ', 'LOJA'),
('AMB', 'AMBATO'), ('RIO', 'RIOBAMBA'), ('MCX', 'MACHALA'), ('IBR', 'IBARRA'), ('ESM', 'ESMERALDAS');

INSERT INTO UNIDADES_MEDIDAS (id_Unidad_Medida, um_Descripcion) VALUES 
('UNI', 'UNIDAD'), ('CJA', 'CAJA'), ('DOC', 'DOCENA'), ('KGM', 'KILOGRAMO'), ('LBR', 'LIBRA'),
('LTR', 'LITRO'), ('GLN', 'GALON'), ('JAV', 'JAVA'), ('SAC', 'SACO'), ('PAQ', 'PAQUETE');

INSERT INTO CATEGORIA_CUENTA (ID_TIPOCUENTA, CAT_DESCRIPCION) VALUES
('1', 'Activo'),
('2', 'Pasivo'),
('3', 'Patrimonio'),
('4', 'Ingresos'),
('5', 'Egresos');

-- 3.2 ORGANIZACIÓN, EMPLEADOS Y USUARIOS

-- (10) DEPARTAMENTOS
INSERT INTO Departamentos (id_Departamento, dep_Nombre, dep_Telefono, dep_Mail, ESTADO_DEP) VALUES
('COMPRAS', 'Compras', '0987654321', 'compras@empresa.com', 'ACT'),
('BODEGAS', 'Bodegas', '0987654322', 'bodegas@empresa.com', 'ACT'),
('VENTAS', 'Ventas', '0987654323', 'ventas@empresa.com', 'ACT'),
('RRHH', 'Recursos Humanos', '0987654324', 'rrhh@empresa.com', 'ACT'),
('CONTAB', 'Contabilidad', '0987654325', 'contabilidad@empresa.com', 'ACT'),
('SISTEM', 'Tecnologías de la Información', '0987654326', 'it@empresa.com', 'ACT'),
('MARKET', 'Marketing', '0987654327', 'marketing@empresa.com', 'ACT'),
('FINAN', 'Finanzas', '0987654328', 'finanzas@empresa.com', 'ACT'),
('LOGIST', 'Logística', '0987654329', 'logistica@empresa.com', 'ACT'),
('ADMINIS', 'Administración', '0987654330', 'administracion@empresa.com', 'ACT');

-- Roles
INSERT INTO ROLES (id_Rol, rol_descripcion, ESTADO_ROL) VALUES 
('ROL-VEN', 'Jefe de Ventas', 'ACT'),
('ROL-COM', 'Jefe de Compras', 'ACT'),
('ROL-CON', 'Jefe Contabilidad', 'ACT'),
('ROL-RH',  'Jefe Talento Humano', 'ACT'),
('ROL-ADM', 'Administrador General', 'ACT');

INSERT INTO Roles (id_Rol, rol_descripcion) VALUES
('C-ANALI', 'Analista de Compras'),
('C-COORD', 'Coordinador de Compras'),
('C-PROVE', 'Especialista en Proveedores'),
('C-PLANI', 'Planificador de Inventario'),
('B-SUPER', 'Supervisor de Almacén'),
('B-OPERA', 'Operador de Almacén'),
('B-COORD', 'Coordinador de Logística'),
('B-ENCAR', 'Encargado de Inventarios'),
('B-AUXIL', 'Auxiliar de Bodega'),
('V-REPRE', 'Representante de Ventas'),
('V-EJECU', 'Ejecutivo de Cuenta'),
('V-ASESO', 'Asesor Comercial'),
('V-COORD', 'Coordinador de Ventas'),
('V-ANALI', 'Analista de Ventas'),
('T-RECLU', 'Reclutador'),
('T-ESPEC', 'Especialista en Desarrollo'),
('T-GENER', 'Generalista de Recursos Humanos'),
('T-COORD', 'Coordinador de Bienestar'),
('T-NOMIN', 'Analista de Compensaciones y Beneficios'),
('CG-CONT', 'Contador General'),
('CG-AUXI', 'Auxiliar Contable'),
('S-CEO', 'CEO Tecnologías Sistemas'),
('S-GER', 'Gerente de Sistemas'),
('S-DBA', 'DBA Data Base Administrator'),
('S-AUX', 'Auxiliar de Sistemas'),
('S-DES', 'Desarrollador de Sistemas'),
('S-PGM', 'Programador de Sistemas');


INSERT INTO Empleados (id_Empleado, emp_Cedula, emp_Apellido1, emp_Apellido2, emp_Nombre1, emp_Nombre2, emp_Sexo, emp_FechaNacimiento, emp_Sueldo, emp_Mail, ESTADO_EMP, id_Departamento, id_Rol) VALUES
(1, '1104567890', 'Perez', 'Lopez', 'Juan', 'Carlos', 'M', '1985-05-12', 1500, 'jclperez1985@empresa.com', 'ACT', 'VENTAS', 'V-REPRE'),
(2, '1104567891', 'Garcia', 'Martinez', 'Maria', 'Elena', 'F', '1992-03-09', 1700, 'megmaria1992@empresa.com', 'ACT', 'COMPRAS', 'C-ANALI'),
(3, '1104567892', 'Rodriguez', 'Smith', 'Carlos', 'Luis', 'M', '1978-07-23', 2200, 'clsrodriguez1978@empresa.com', 'ACT', 'BODEGAS', 'B-OPERA'),
(4, '1104567893', 'Smith', 'Johnson', 'Luis', 'James', 'M', '1965-10-18', 1300, 'ljssmith1965@empresa.com', 'ACT', 'RRHH', 'T-RECLU'),
(5, '1104567894', 'Martinez', 'Davis', 'Ana', 'Maria', 'F', '1983-06-21', 1800, 'amdavis1983@empresa.com', 'ACT', 'LOGIST', 'B-COORD'),
(6, '1104567895', 'Lopez', 'Brown', 'Gabriela', 'Sarah', 'F', '1971-02-12', 2000, 'gsbrown1971@empresa.com', 'ACT', 'MARKET', 'C-PLANI'),
(7, '1104567896', 'Wilson', 'Miller', 'Pedro', 'James', 'M', '1989-11-08', 1750, 'pjwilson1989@empresa.com', 'ACT', 'ADMINIS', 'S-GER'),
(8, '1104567897', 'Johnson', 'Martinez', 'Michael', 'Carlos', 'M', '1990-07-19', 2100, 'mcmartinez1990@empresa.com', 'ACT', 'SISTEM', 'S-CEO'),
(9, '1104567898', 'Davis', 'Garcia', 'Jennifer', 'Elena', 'F', '1982-01-05', 1900, 'jegarcia1982@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(10, '1104567899', 'Martinez', 'Lopez', 'Luis', 'Juan', 'M', '1973-04-23', 1600, 'ljmartinez1973@empresa.com', 'ACT', 'VENTAS', 'V-EJECU'),
(11, '1104567800', 'Perez', 'Smith', 'James', 'Luis', 'M', '1987-06-30', 1350, 'jlpsmith1987@empresa.com', 'ACT', 'BODEGAS', 'B-ENCAR'),
(12, '1104567801', 'Garcia', 'Johnson', 'Ana', 'Maria', 'F', '1991-03-17', 1550, 'amjgarcia1991@empresa.com', 'ACT', 'COMPRAS', 'C-COORD'),
(13, '1104567802', 'Rodriguez', 'Brown', 'Pedro', 'Michael', 'M', '1968-09-14', 1450, 'pmbrown1968@empresa.com', 'ACT', 'RRHH', 'T-ESPEC'),
(14, '1104567803', 'Smith', 'Davis', 'Carlos', 'Jennifer', 'M', '1995-08-11', 1850, 'cjdsmithe1995@empresa.com', 'ACT', 'MARKET', 'T-NOMIN'),
(15, '1104567804', 'Johnson', 'Miller', 'Sarah', 'Luis', 'F', '1979-12-21', 2400, 'sljohnson1979@empresa.com', 'ACT', 'CONTAB', 'CG-AUXI'),
(16, '1104567805', 'Wilson', 'Martinez', 'Gabriela', 'James', 'F', '1984-10-07', 1300, 'gimartinez1984@empresa.com', 'ACT', 'FINAN', 'V-ANALI'),
(17, '1104567806', 'Davis', 'Garcia', 'Juan', 'Carlos', 'M', '1990-06-29', 2000, 'jdavis1990@empresa.com', 'ACT', 'VENTAS', 'V-REPRE'),
(18, '1104567807', 'Martinez', 'Lopez', 'Ana', 'Michael', 'F', '1980-01-18', 1950, 'amlopez1980@empresa.com', 'ACT', 'LOGIST', 'B-SUPER'),
(19, '1104567808', 'Garcia', 'Smith', 'Luis', 'Carlos', 'M', '1977-05-14', 2500, 'lcsmith1977@empresa.com', 'ACT', 'RRHH', 'T-COORD'),
(20, '1104567809', 'Wilson', 'Johnson', 'James', 'Sarah', 'M', '1992-02-20', 1800, 'jsjohnson1992@empresa.com', 'ACT', 'BODEGAS', 'B-AUXIL'),
(21, '0104567810', 'Smith', 'Brown', 'Michael', 'Elena', 'M', '1985-11-24', 1750, 'melena1985@empresa.com', 'ACT', 'MARKET', 'C-ANALI'),
(22, '0104567811', 'Johnson', 'Martinez', 'Carlos', 'Luis', 'M', '1988-07-14', 2000, 'clmartinez1988@empresa.com', 'ACT', 'SISTEM', 'S-PGM'),
(23, '0104567812', 'Brown', 'Lopez', 'Elena', 'Gabriela', 'F', '1970-10-19', 1600, 'elgabriela1970@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(24, '0104567813', 'Davis', 'Garcia', 'Pedro', 'James', 'M', '1991-09-17', 1850, 'pgarcia1991@empresa.com', 'ACT', 'CONTAB', 'CG-AUXI'),
(25, '0104567814', 'Martinez', 'Smith', 'Luis', 'Carlos', 'M', '1975-04-15', 1400, 'lcsmith1975@empresa.com', 'ACT', 'VENTAS', 'V-ASESO'),
(26, '0104567815', 'Lopez', 'Wilson', 'Ana', 'Jennifer', 'F', '1993-11-25', 2100, 'alwilson1993@empresa.com', 'ACT', 'MARKET', 'C-COORD'),
(27, '0104567816', 'Johnson', 'Brown', 'Carlos', 'James', 'M', '1969-06-06', 1550, 'cjbbrown1969@empresa.com', 'ACT', 'RRHH', 'T-GENER'),
(28, '0104567817', 'Garcia', 'Davis', 'Michael', 'Gabriela', 'M', '1982-03-27', 2000, 'mgdavis1982@empresa.com', 'ACT', 'BODEGAS', 'B-COORD'),
(29, '0104567818', 'Rodriguez', 'Martinez', 'Sarah', 'Juan', 'F', '1996-01-08', 1750, 'sjmartinez1996@empresa.com', 'ACT', 'ADMINIS', 'S-DBA'),
(30, '0104567819', 'Smith', 'Lopez', 'James', 'Luis', 'M', '1984-12-09', 1950, 'jlpsmith1984@empresa.com', 'ACT', 'VENTAS', 'V-EJECU'),
(31, '0104567820', 'Martinez', 'Wilson', 'Ana', 'Carlos', 'F', '1978-07-05', 1450, 'acwilson1978@empresa.com', 'ACT', 'VENTAS', 'V-ANALI'),
(32, '0104567822', 'Perez', 'Lopez', 'Juan', 'Gabriela', 'M', '1986-04-12', 1950, 'jglperez1986@empresa.com', 'ACT', 'MARKET', 'T-ESPEC'),
(33, '0104567823', 'Johnson', 'Martinez', 'Elena', 'Luis', 'F', '1990-12-02', 2200, 'elmjohnson1990@empresa.com', 'ACT', 'RRHH', 'T-COORD'),
(34, '0104567824', 'Brown', 'Smith', 'Carlos', 'James', 'M', '1985-09-30', 2100, 'cjbsmith1985@empresa.com', 'ACT', 'LOGIST', 'B-SUPER'),
(35, '0104567825', 'Davis', 'Garcia', 'Maria', 'Ana', 'F', '1973-02-14', 1650, 'madavis1973@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(36, '0104567826', 'Lopez', 'Johnson', 'Pedro', 'Michael', 'M', '1976-06-08', 1550, 'pmljohnson1976@empresa.com', 'ACT', 'ADMINIS', 'S-CEO'),
(37, '0104567827', 'Martinez', 'Rodriguez', 'Gabriela', 'Sarah', 'F', '1988-05-27', 2000, 'gsrmartinez1988@empresa.com', 'ACT', 'COMPRAS', 'C-PLANI'),
(38, '0104567828', 'Garcia', 'Brown', 'Luis', 'Carlos', 'M', '1972-03-13', 1800, 'lcgarcia1972@empresa.com', 'ACT', 'BODEGAS', 'B-OPERA'),
(39, '0104567829', 'Smith', 'Davis', 'James', 'Luis', 'M', '1987-08-17', 2400, 'jlsmith1987@empresa.com', 'ACT', 'RRHH', 'T-GENER'),
(40, '0104567830', 'Wilson', 'Miller', 'Michael', 'Sarah', 'M', '1994-10-23', 1450, 'mswilson1994@empresa.com', 'ACT', 'MARKET', 'C-ANALI'),
(41, '0104567831', 'Brown', 'Perez', 'Jennifer', 'Carlos', 'F', '1983-01-19', 2300, 'jcbrown1983@empresa.com', 'ACT', 'SISTEM', 'S-PGM'),
(42, '0104567832', 'Garcia', 'Martinez', 'Juan', 'Elena', 'M', '1981-07-28', 1900, 'jegmartinez1981@empresa.com', 'ACT', 'LOGIST', 'B-ENCAR'),
(43, '0104567833', 'Rodriguez', 'Lopez', 'Ana', 'James', 'F', '1974-05-09', 1400, 'ajrodriguez1974@empresa.com', 'ACT', 'VENTAS', 'V-EJECU'),
(44, '0104567834', 'Davis', 'Smith', 'Luis', 'Pedro', 'M', '1985-02-25', 1550, 'lpdsmith1985@empresa.com', 'ACT', 'CONTAB', 'CG-AUXI'),
(45, '0104567835', 'Martinez', 'Wilson', 'Carlos', 'Sarah', 'M', '1992-09-18', 2250, 'csmwilson1992@empresa.com', 'ACT', 'BODEGAS', 'B-SUPER'),
(46, '0104567836', 'Smith', 'Davis', 'Elena', 'Gabriela', 'F', '1984-03-31', 2500, 'egsmith1984@empresa.com', 'ACT', 'MARKET', 'T-RECLU'),
(47, '0104567837', 'Johnson', 'Garcia', 'Michael', 'Luis', 'M', '1979-11-05', 2100, 'mljohnson1979@empresa.com', 'ACT', 'VENTAS', 'V-ASESO'),
(48, '0104567838', 'Perez', 'Lopez', 'Gabriela', 'Carlos', 'F', '1989-08-22', 1950, 'gclperez1989@empresa.com', 'ACT', 'RRHH', 'T-NOMIN'),
(49, '0104567839', 'Wilson', 'Brown', 'Maria', 'Elena', 'F', '1991-12-12', 1800, 'mebwilson1991@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(50, '0104567840', 'Lopez', 'Johnson', 'Michael', 'James', 'M', '1989-08-16', 2500, 'mjlmichael1989@empresa.com', 'ACT', 'RRHH', 'T-RECLU'),
(51, '0104567841', 'Martinez', 'Lopez', 'Pedro', 'Luis', 'M', '1977-11-23', 1650, 'pllopez1977@empresa.com', 'ACT', 'COMPRAS', 'C-ANALI'),
(52, '0104567842', 'Garcia', 'Wilson', 'Carlos', 'James', 'M', '1982-05-12', 1750, 'cwilson1982@empresa.com', 'ACT', 'BODEGAS', 'B-OPERA'),
(53, '0104567843', 'Smith', 'Brown', 'Maria', 'Sarah', 'F', '1990-09-17', 1450, 'msbrown1990@empresa.com', 'ACT', 'RRHH', 'T-ESPEC'),
(54, '0104567844', 'Rodriguez', 'Davis', 'Juan', 'Ana', 'M', '1974-07-30', 1500, 'jardav1974@empresa.com', 'ACT', 'LOGIST', 'B-ENCAR'),
(55, '0104567845', 'Perez', 'Martinez', 'Luis', 'Elena', 'M', '1968-08-04', 1900, 'lmper1970@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(56, '0104567846', 'Martinez', 'Johnson', 'Sarah', 'Gabriela', 'F', '1985-06-23', 1550, 'sgjohnson1985@empresa.com', 'ACT', 'SISTEM', 'S-GER'),
(57, '0104567847', 'Lopez', 'Smith', 'Elena', 'Luis', 'F', '1993-02-19', 1350, 'elsmith1993@empresa.com', 'ACT', 'RRHH', 'T-RECLU'),
(58, '0104567848', 'Johnson', 'Garcia', 'Michael', 'James', 'M', '1990-03-09', 2250, 'mjgarcia1990@empresa.com', 'ACT', 'VENTAS', 'V-ANALI'),
(59, '0104567849', 'Brown', 'Lopez', 'Carlos', 'Ana', 'M', '1975-04-11', 2450, 'cabrown1975@empresa.com', 'ACT', 'MARKET', 'C-PLANI'),
(60, '0104567850', 'Wilson', 'Davis', 'Luis', 'Sarah', 'M', '1988-10-22', 1400, 'lsdavis1988@empresa.com', 'ACT', 'BODEGAS', 'B-SUPER'),
(61, '0104567851', 'Garcia', 'Perez', 'Pedro', 'Gabriela', 'M', '1973-11-12', 1800, 'gperez1973@empresa.com', 'ACT', 'FINAN', 'CG-AUXI'),
(62, '0104567852', 'Smith', 'Wilson', 'Jennifer', 'Carlos', 'F', '1987-08-30', 2000, 'jcsmith1987@empresa.com', 'ACT', 'LOGIST', 'B-COORD'),
(63, '0104567853', 'Johnson', 'Martinez', 'Maria', 'Juan', 'F', '1992-09-18', 1550, 'mjmartinez1992@empresa.com', 'ACT', 'VENTAS', 'V-EJECU'),
(64, '0104567854', 'Lopez', 'Brown', 'Ana', 'Luis', 'F', '1969-12-15', 1600, 'albrown1969@empresa.com', 'ACT', 'RRHH', 'T-ESPEC'),
(65, '0104567855', 'Perez', 'Garcia', 'Luis', 'James', 'M', '1978-05-07', 1350, 'ljgarcia1978@empresa.com', 'ACT', 'COMPRAS', 'C-COORD'),
(66, '0104567856', 'Wilson', 'Smith', 'Gabriela', 'Maria', 'F', '1984-03-26', 1950, 'gmsmith1984@empresa.com', 'ACT', 'MARKET', 'C-ANALI'),
(67, '0104567857', 'Brown', 'Davis', 'Carlos', 'Pedro', 'M', '1980-12-30', 2500, 'cpbrown1980@empresa.com', 'ACT', 'SISTEM', 'S-PGM'),
(68, '0104567858', 'Martinez', 'Johnson', 'Elena', 'Sarah', 'F', '1981-04-01', 1500, 'emartinez1981@empresa.com', 'ACT', 'LOGIST', 'B-ENCAR'),
(69, '0104567859', 'Rodriguez', 'Martinez', 'James', 'Gabriela', 'M', '1994-11-05', 2050, 'jmartinez1994@empresa.com', 'ACT', 'BODEGAS', 'B-OPERA'),
(70, '0104567860', 'Garcia', 'Lopez', 'Juan', 'Ana', 'M', '1991-02-28', 1650, 'jgarcia1991@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(71, '0104567861', 'Martinez', 'Johnson', 'Pedro', 'James', 'M', '1986-02-14', 1650, 'pjmartinez1986@empresa.com', 'ACT', 'VENTAS', 'V-ANALI'),
(72, '0104567862', 'Garcia', 'Wilson', 'Maria', 'Elena', 'F', '1993-06-25', 1750, 'mewilson1993@empresa.com', 'ACT', 'COMPRAS', 'C-ANALI'),
(73, '0104567863', 'Smith', 'Davis', 'Carlos', 'Luis', 'M', '1988-03-08', 1600, 'clsdsith1988@empresa.com', 'ACT', 'RRHH', 'T-GENER'),
(74, '0104567864', 'Perez', 'Garcia', 'Jennifer', 'Gabriela', 'F', '1977-01-29', 2300, 'jgperez1977@empresa.com', 'ACT', 'BODEGAS', 'B-SUPER'),
(75, '0104567865', 'Wilson', 'Brown', 'Ana', 'Sarah', 'F', '1990-09-15', 1450, 'aswbrown1990@empresa.com', 'ACT', 'FINAN', 'CG-AUXI'),
(76, '0104567866', 'Davis', 'Martinez', 'Luis', 'Carlos', 'M', '1982-10-19', 1950, 'lcdavism1982@empresa.com', 'ACT', 'SISTEM', 'S-GER'),
(77, '0104567867', 'Lopez', 'Smith', 'Michael', 'Elena', 'M', '1985-12-10', 2150, 'melosmith1985@empresa.com', 'ACT', 'VENTAS', 'V-ASESO'),
(78, '0104567868', 'Johnson', 'Brown', 'Gabriela', 'Ana', 'F', '1992-11-26', 2100, 'gbrownjohnson1992@empresa.com', 'ACT', 'RRHH', 'T-ESPEC'),
(79, '0104567869', 'Brown', 'Lopez', 'Pedro', 'Juan', 'M', '1980-04-03', 1800, 'pjbrown1980@empresa.com', 'ACT', 'CONTAB', 'CG-CONT'),
(80, '0104567870', 'Rodriguez', 'Miller', 'Sarah', 'James', 'F', '1979-07-11', 2400, 'sjrodriguez1979@empresa.com', 'ACT', 'MARKET', 'C-COORD'),
(81, '0104567871', 'Martinez', 'Smith', 'Juan', 'Carlos', 'M', '1990-05-14', 1550, 'jcsmith1990@empresa.com', 'ACT', 'ADMINIS', 'S-DBA'),
(82, '0104567872', 'Perez', 'Davis', 'James', 'Michael', 'M', '1986-06-22', 2200, 'jmperez1986@empresa.com', 'ACT', 'BODEGAS', 'B-ENCAR'),
(83, '0104567873', 'Garcia', 'Johnson', 'Luis', 'Gabriela', 'M', '1975-09-09', 1350, 'gjohnson1975@empresa.com', 'ACT', 'LOGIST', 'B-OPERA'),
(84, '0104567874', 'Lopez', 'Garcia', 'Ana', 'Sarah', 'F', '1984-02-11', 1400, 'asglopez1984@empresa.com', 'ACT', 'FINAN', 'CG-AUXI'),
(85, '0104567875', 'Wilson', 'Martinez', 'Carlos', 'Luis', 'M', '1991-08-29', 2050, 'cwilsonmartinez1991@empresa.com', 'ACT', 'VENTAS', 'V-REPRE'),
(86, '0104567876', 'Rodriguez', 'Brown', 'Gabriela', 'Elena', 'F', '1982-04-20', 1700, 'rjgabriela1982@empresa.com', 'ACT', 'RRHH', 'T-COORD'),
(87, '0104567877', 'Davis', 'Smith', 'Sarah', 'James', 'F', '1989-07-23', 1500, 'sjamesdavissmith1989@empresa.com', 'ACT', 'LOGIST', 'B-ENCAR'),
(88, '0104567878', 'Martinez', 'Wilson', 'Maria', 'Elena', 'F', '1971-11-03', 1800, 'mewilson1971@empresa.com', 'ACT', 'COMPRAS', 'C-PLANI'),
(89, '0104567879', 'Lopez', 'Rodriguez', 'Juan', 'Luis', 'M', '1973-06-07', 1450, 'jrodriguez1973@empresa.com', 'ACT', 'RRHH', 'T-NOMIN'),
(90, '0104567880', 'Smith', 'Davis', 'Elena', 'Ana', 'F', '1983-09-21', 2250, 'sdana1983@empresa.com', 'ACT', 'BODEGAS', 'B-SUPER'),
(91, '1704567881', 'Martinez', 'Lopez', 'Carlos', 'Pedro', 'M', '1987-01-14', 1650, 'clperez1987@empresa.com', 'ACT', 'COMPRAS', 'C-ANALI'),
(92, '1704567882', 'Garcia', 'Johnson', 'Maria', 'Ana', 'F', '1974-08-23', 2000, 'majohnson1974@empresa.com', 'ACT', 'BODEGAS', 'B-ENCAR'),
(93, '1704567883', 'Smith', 'Davis', 'Luis', 'Gabriela', 'M', '1985-02-11', 1750, 'lgsmith1985@empresa.com', 'ACT', 'RRHH', 'T-COORD'),
(94, '1704567884', 'Lopez', 'Brown', 'Jennifer', 'Sarah', 'F', '1991-03-29', 1850, 'jslopez1991@empresa.com', 'ACT', 'MARKET', 'C-ANALI'),
(95, '1704567885', 'Perez', 'Wilson', 'Michael', 'James', 'M', '1978-05-12', 1500, 'mjwilson1978@empresa.com', 'ACT', 'FINAN', 'CG-AUXI'),
(96, '1704567886', 'Johnson', 'Martinez', 'Ana', 'Elena', 'F', '1983-04-19', 2150, 'aemartinez1983@empresa.com', 'ACT', 'SISTEM', 'S-GER'),
(97, '1704567887', 'Rodriguez', 'Lopez', 'Pedro', 'Carlos', 'M', '1992-10-23', 2300, 'pclopez1992@empresa.com', 'ACT', 'VENTAS', 'V-EJECU'),
(98, '1704567888', 'Brown', 'Garcia', 'Gabriela', 'Luis', 'F', '1976-06-17', 1750, 'glgarcia1976@empresa.com', 'ACT', 'RRHH', 'T-RECLU'),
(99, '1708558430', 'Cóndor', 'Cruz', 'Javier', 'Wilfrido', 'M', '1965-09-14', 2200, 'ccjw1965@empresa.com', 'ACT', 'SISTEM', 'S-CEO'),
(100, '1704567890', 'Smith', 'Rodriguez', 'Carlos', 'Juan', 'M', '1980-09-21', 1950, 'cjrsmith1980@empresa.com', 'ACT', 'ADMINIS', 'S-DBA'),
(101, '1704567891', 'Lopez', 'Martinez', 'Luis', 'Elena', 'M', '1990-08-15', 1600, 'lemartinez1990@empresa.com', 'ACT', 'COMPRAS', 'C-COORD'),
(102, '1704567892', 'Perez', 'Johnson', 'Elena', 'Maria', 'F', '1987-12-12', 1400, 'emperez1987@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(103, '1704567893', 'Brown', 'Wilson', 'Gabriela', 'Sarah', 'F', '1995-02-02', 1700, 'gsbrown1995@empresa.com', 'ACT', 'MARKET', 'T-NOMIN'),
(104, '1704567894', 'Garcia', 'Lopez', 'Carlos', 'Luis', 'M', '1981-11-07', 1500, 'cgarcia1981@empresa.com', 'ACT', 'RRHH', 'T-ESPEC'),
(105, '1704567895', 'Martinez', 'Brown', 'Pedro', 'Ana', 'M', '1984-04-30', 2200, 'pbrown1984@empresa.com', 'ACT', 'BODEGAS', 'B-OPERA'),
(106, '1704567896', 'Davis', 'Garcia', 'Michael', 'James', 'M', '1973-07-13', 2400, 'mgarcia1973@empresa.com', 'ACT', 'LOGIST', 'B-ENCAR'),
(107, '1704567897', 'Rodriguez', 'Smith', 'Maria', 'Elena', 'F', '1989-03-17', 1900, 'msmith1989@empresa.com', 'ACT', 'VENTAS', 'V-ANALI'),
(108, '1704567898', 'Lopez', 'Wilson', 'Carlos', 'Gabriela', 'M', '1976-08-11', 2100, 'cwilson1976@empresa.com', 'ACT', 'RRHH', 'T-COORD'),
(109, '1704567899', 'Perez', 'Brown', 'Juan', 'Luis', 'M', '1982-10-29', 1450, 'jlbrown1982@empresa.com', 'ACT', 'FINAN', 'CG-AUXI'),
(110, '1704567900', 'Johnson', 'Garcia', 'Sarah', 'James', 'F', '1991-01-19', 1700, 'sgarcia1991@empresa.com', 'ACT', 'ADMINIS', 'S-CEO'),
(111, '1704567901', 'Martinez', 'Johnson', 'Ana', 'Maria', 'F', '1977-04-16', 1800, 'amjohnson1977@empresa.com', 'ACT', 'RRHH', 'T-GENER'),
(112, '1704567902', 'Garcia', 'Smith', 'Pedro', 'James', 'M', '1983-12-10', 1500, 'pjsmith1983@empresa.com', 'ACT', 'BODEGAS', 'B-OPERA'),
(113, '1704567903', 'Lopez', 'Brown', 'Luis', 'Carlos', 'M', '1991-08-04', 1550, 'lcbrown1991@empresa.com', 'ACT', 'MARKET', 'C-ANALI'),
(114, '1704567904', 'Perez', 'Martinez', 'James', 'Elena', 'M', '1986-07-09', 1750, 'jemartinez1986@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(115, '1704567905', 'Johnson', 'Wilson', 'Maria', 'Gabriela', 'F', '1972-03-27', 2200, 'mgwilson1972@empresa.com', 'ACT', 'COMPRAS', 'C-PLANI'),
(116, '1704567906', 'Brown', 'Garcia', 'Sarah', 'Michael', 'F', '1990-10-20', 1600, 'smgarcia1990@empresa.com', 'ACT', 'VENTAS', 'V-ASESO'),
(117, '1704567907', 'Martinez', 'Davis', 'Carlos', 'Pedro', 'M', '1979-05-01', 1900, 'cpdavis1979@empresa.com', 'ACT', 'SISTEM', 'S-PGM'),
(118, '1704567908', 'Smith', 'Lopez', 'Elena', 'Ana', 'F', '1988-01-25', 1450, 'elaslopez1988@empresa.com', 'ACT', 'RRHH', 'T-RECLU'),
(119, '1704567909', 'Rodriguez', 'Johnson', 'Michael', 'Luis', 'M', '1976-08-07', 2300, 'mjohnson1976@empresa.com', 'ACT', 'BODEGAS', 'B-SUPER'),
(120, '1704567910', 'Garcia', 'Brown', 'Ana', 'James', 'F', '1982-09-15', 1700, 'ajbrown1982@empresa.com', 'ACT', 'MARKET', 'T-ESPEC'),
(121, '1704567911', 'Martinez', 'Smith', 'Carlos', 'Juan', 'M', '1987-11-18', 2150, 'cjmsmith1987@empresa.com', 'ACT', 'LOGIST', 'B-ENCAR'),
(122, '1704567912', 'Davis', 'Wilson', 'Jennifer', 'Maria', 'F', '1975-04-02', 1500, 'jmwilson1975@empresa.com', 'ACT', 'ADMINIS', 'S-DBA'),
(123, '1704567913', 'Lopez', 'Garcia', 'Luis', 'Elena', 'M', '1992-06-11', 2500, 'leogarcia1992@empresa.com', 'ACT', 'VENTAS', 'V-EJECU'),
(124, '1704567914', 'Perez', 'Brown', 'Gabriela', 'Sarah', 'F', '1983-08-14', 1850, 'gbrown1983@empresa.com', 'ACT', 'RRHH', 'T-NOMIN'),
(125, '1704567915', 'Smith', 'Johnson', 'Pedro', 'James', 'M', '1974-12-25', 1300, 'pjjohnson1974@empresa.com', 'ACT', 'CONTAB', 'CG-AUXI'),
(126, '1704567916', 'Johnson', 'Martinez', 'Ana', 'Gabriela', 'F', '1986-03-29', 1750, 'agmjohnson1986@empresa.com', 'ACT', 'BODEGAS', 'B-OPERA'),
(127, '1704567917', 'Rodriguez', 'Davis', 'Carlos', 'Luis', 'M', '1989-10-08', 1900, 'cldavies1989@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(128, '1704567918', 'Brown', 'Garcia', 'Michael', 'Ana', 'M', '1971-05-06', 1450, 'magarcia1971@empresa.com', 'ACT', 'MARKET', 'C-COORD'),
(129, '1704567919', 'Martinez', 'Wilson', 'Elena', 'Luis', 'F', '1981-07-17', 1950, 'elwilson1981@empresa.com', 'ACT', 'LOGIST', 'B-ENCAR'),
(130, '1704567920', 'Smith', 'Lopez', 'Juan', 'Sarah', 'M', '1995-02-28', 2100, 'jslopez1995@empresa.com', 'ACT', 'RRHH', 'T-RECLU'),
(131, '1704567921', 'Johnson', 'Perez', 'Ana', 'Maria', 'F', '1980-05-03', 1750, 'amperez1980@empresa.com', 'ACT', 'RRHH', 'T-ESPEC'),
(132, '1704567922', 'Lopez', 'Garcia', 'Luis', 'Gabriela', 'M', '1976-04-18', 2000, 'lglopez1976@empresa.com', 'ACT', 'SISTEM', 'S-PGM'),
(133, '1704567923', 'Rodriguez', 'Brown', 'Michael', 'Carlos', 'M', '1992-06-10', 1600, 'mcrod1972@empresa.com', 'ACT', 'BODEGAS', 'B-OPERA'),
(134, '1704567924', 'Garcia', 'Smith', 'Elena', 'Sarah', 'F', '1984-09-21', 1800, 'esmith1984@empresa.com', 'ACT', 'CONTAB', 'CG-CONT'),
(135, '1704567925', 'Davis', 'Martinez', 'Pedro', 'James', 'M', '1989-07-14', 2100, 'pjmartinez1989@empresa.com', 'ACT', 'MARKET', 'C-PLANI'),
(136, '1704567926', 'Smith', 'Johnson', 'Maria', 'Luis', 'F', '1974-02-11', 1450, 'msjohnson1974@empresa.com', 'ACT', 'VENTAS', 'V-ANALI'),
(137, '1704567927', 'Brown', 'Lopez', 'Carlos', 'James', 'M', '1983-10-23', 2500, 'cllopez1983@empresa.com', 'ACT', 'RRHH', 'T-RECLU'),
(138, '1704567928', 'Wilson', 'Rodriguez', 'Gabriela', 'Ana', 'F', '1991-08-07', 1500, 'garodriguez1991@empresa.com', 'ACT', 'BODEGAS', 'B-ENCAR'),
(139, '1704567929', 'Martinez', 'Wilson', 'Luis', 'Michael', 'M', '1979-12-15', 2400, 'lmwilson1979@empresa.com', 'ACT', 'FINAN', 'CG-AUXI'),
(140, '1704567930', 'Perez', 'Johnson', 'Jennifer', 'Gabriela', 'F', '1990-04-28', 1350, 'jgjohnson1990@empresa.com', 'ACT', 'LOGIST', 'B-SUPER'),
(141, '1704567931', 'Lopez', 'Smith', 'Carlos', 'Pedro', 'M', '1972-06-09', 1550, 'csmith1972@empresa.com', 'ACT', 'ADMINIS', 'S-GER'),
(142, '1704567932', 'Garcia', 'Brown', 'Ana', 'James', 'F', '1994-02-27', 2250, 'agbrown1994@empresa.com', 'ACT', 'COMPRAS', 'C-ANALI'),
(143, '1704567933', 'Martinez', 'Davis', 'Michael', 'Sarah', 'M', '1985-09-04', 1700, 'msdavis1985@empresa.com', 'ACT', 'VENTAS', 'V-REPRE'),
(144, '1704567934', 'Rodriguez', 'Lopez', 'Elena', 'Carlos', 'F', '1982-05-25', 1900, 'ecrodriguez1982@empresa.com', 'ACT', 'MARKET', 'C-COORD'),
(145, '1704567935', 'Wilson', 'Garcia', 'James', 'Luis', 'M', '1977-01-29', 1400, 'jgarcia1977@empresa.com', 'ACT', 'RRHH', 'T-COORD'),
(146, '1704567936', 'Perez', 'Johnson', 'Sarah', 'Maria', 'F', '1988-11-17', 2200, 'smjohnson1988@empresa.com', 'ACT', 'BODEGAS', 'B-OPERA'),
(147, '1704567937', 'Lopez', 'Smith', 'Pedro', 'Gabriela', 'M', '1991-03-18', 2050, 'pglopez1991@empresa.com', 'ACT', 'FINAN', 'CG-CONT'),
(148, '1704567938', 'Brown', 'Wilson', 'Ana', 'Michael', 'F', '1975-12-29', 1600, 'amwilson1975@empresa.com', 'ACT', 'LOGIST', 'B-COORD'),
(149, '1704567939', 'Garcia', 'Martinez', 'Luis', 'Elena', 'M', '1980-08-19', 1850, 'lmartinez1980@empresa.com', 'ACT', 'ADMINIS', 'S-DBA'),
(150, '1704567940', 'Rodriguez', 'Brown', 'Carlos', 'James', 'M', '1986-12-31', 1500, 'cbrown1986@empresa.com', 'ACT', 'VENTAS', 'V-EJECU');

-- Usuarios (Clave 1234 texto plano)
INSERT INTO USUARIOS (id_Empleado, id_Rol, usr_Login, usr_Password, ESTADO_USR) VALUES 
(1, 'ROL-VEN', 'jefe.ventas', '1234', 'ACT'),
(2, 'ROL-COM', 'jefe.compras', '1234', 'ACT'),
(3, 'ROL-CON', 'jefe.conta',   '1234', 'ACT'),
(4,  'ROL-RH',  'jefe.rrhh',    '1234', 'ACT'),
(5, 'ROL-ADM', 'admin',        '1234', 'ACT');

-- 3.3 PLAN DE CUENTAS (Inicializado en 0)
INSERT INTO CUENTAS (ID_CODIGOCUENTA, ID_TIPOCUENTA, CUE_NOMBRECUENTA, CUE_DESCRIPCION, CUE_TIPOCUENTA, CUE_DEB00, CUE_DEB01, CUE_DEB02, CUE_DEB03, CUE_DEB04, CUE_DEB05, CUE_DEB06, CUE_DEB07, CUE_DEB08, CUE_DEB09, CUE_DEB10, CUE_DEB11, CUE_DEB12, CUE_DEB13, CUE_HAB00, CUE_HAB01, CUE_HAB02, CUE_HAB03, CUE_HAB04, CUE_HAB05, CUE_HAB06, CUE_HAB07, CUE_HAB08, CUE_HAB09, CUE_HAB10, CUE_HAB11, CUE_HAB12, CUE_HAB13, CUE_USERID, CUE_ESTADOCUENTA) VALUES
-- ID_CODICUENTA, ID_TIPOCUENTA, CUE_NOMBRECUENTA, CUE_DESCRIPCION, CUE_TIPOCUENTA, (28 campos de saldo a 0.00), CUE_USERID, CUE_ESTADOCUENTA

('1.', '1', 'Activos', 'Activos', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.', '1', 'Corriente', 'Corriente', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.', '1', 'Efectivo Y Equivalentes De Efectivo', 'Efectivo Y Equivalentes De Efectivo', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.01.', '1', 'Caja', 'Caja', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.01.01', '1', 'Caja General', 'Caja General', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.01.02', '1', 'Caja Tarjetas', 'Caja Tarjetas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.01.03', '1', 'Caja Posfechados', 'Caja Posfechados', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.01.04', '1', 'Caja Chica', 'Caja Chica', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.01.05', '1', 'Transferencias Internas (Cero)', 'Transferencias Internas (Cero)', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.01.06', '1', 'Caja Reposición Administración', 'Caja Reposición Administración', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.01.07', '1', 'Fondo Rotativo ', 'Fondo Rotativo ', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.01.99', '1', 'Cuenta de Regularización(Siempre Cero)', 'Cuenta de Regularización(Siempre Cero)', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.02.', '1', 'Bancos', 'Bancos', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.02.01', '1', 'Banco Pichincha', 'Banco Pichincha', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.02.02', '1', 'Produbanco', 'Produbanco', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.01.02.03', '1', 'Banco Austro', 'Banco Austro', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.', '1', 'Activos Financieros', 'Activos Financieros', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.01.', '1', 'Activos Financieros A Valor Razonable Con Cambios En Resulta', 'Activos Financieros A Valor Razonable Con Cambios En Resulta', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.01.01', '1', 'Activos Financieros', 'Activos Financieros', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.02.', '1', 'Activos Financieros Disponibles Para La Venta', 'Activos Financieros Disponibles Para La Venta', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.03.', '1', 'Activos Financieros Mantenidos Hasta Su Vencimiento', 'Activos Financieros Mantenidos Hasta Su Vencimiento', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.04.', '1', '(-) Provisión Por Deterioro', '(-) Provisión Por Deterioro', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.04.01', '1', '(-) Provisión Por Deterioro', '(-) Provisión Por Deterioro', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.05.', '1', 'Documentos Y Cuentas Por Cobrar Clientes No Relacionados', 'Documentos Y Cuentas Por Cobrar Clientes No Relacionados', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.05.01', '1', 'Clientes', 'Clientes', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.05.02', '1', 'Empleados', 'Empleados', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.05.03', '1', 'Cheques Devueltos, Protestados O Cambio Cheques', 'Cheques Devueltos, Protestados O Cambio Cheques', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.05.04', '1', 'Transitoria Cruce Clientes (Siempre Cero)', 'Transitoria Cruce Clientes (Siempre Cero)', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.05.05', '1', 'Transitoria Retenciones Atrazadas (Siempre Cero)', 'Transitoria Retenciones Atrazadas (Siempre Cero)', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.06.', '1', 'Documentos Y Cuentas Por Cobrar Clientes Relacionados', 'Documentos Y Cuentas Por Cobrar Clientes Relacionados', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.06.01', '1', 'Clientes Relacionados', 'Clientes Relacionados', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.07.', '1', 'Otras Cuentas Por Cobrar Relacionadas', 'Otras Cuentas Por Cobrar Relacionadas', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.07.01', '1', 'Prestamos Accionistas', 'Prestamos Accionistas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.07.02', '1', 'Otras Cuentas Por Cobrar Relacionados', 'Otras Cuentas Por Cobrar Relacionados', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.07.03', '1', 'Dividendos Accionistas / Socios', 'Dividendos Accionistas / Socios', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.08.', '1', 'Cuentas Por Cobrar Empleados', 'Cuentas Por Cobrar Empleados', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.08.01', '1', 'Anticipo Empleados', 'Anticipo Empleados', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.08.02', '1', 'Prestamos Empleados', 'Prestamos Empleados', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.08.03', '1', 'Faltantes Caja Por Cobrar', 'Faltantes Caja Por Cobrar', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.09.', '1', 'Cuentas Por Cobrar', 'Cuentas Por Cobrar', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.09.01', '1', 'Garantía Por Arriendo Oficina', 'Garantía Por Arriendo Oficina', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.09.02', '1', 'Cheques En Garantía', 'Cheques En Garantía', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.09.03', '1', 'Otras Cuentas Por Cobrar', 'Otras Cuentas Por Cobrar', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.11.', '1', '(-) Provisión De Cuentas Incobrables', '(-) Provisión De Cuentas Incobrables', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.02.11.01', '1', '(-) Provisión De Cuentas Incobrables', '(-) Provisión De Cuentas Incobrables', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.', '1', 'Inventarios', 'Inventarios', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.01.', '1', 'Inv. De Prod. Terminados', 'Inv. De Prod. Terminados', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.01.01', '1', 'Inventarios De Prod. Terminados Con Iva', 'Inventarios De Prod. Terminados Con Iva', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.01.02', '1', 'Inventarios De Prod. Terminados Sin Iva', 'Inventarios De Prod. Terminados Sin Iva', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.01.03', '1', 'Inventario Transitorio Ofertas', 'Inventario Transitorio Ofertas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.01.04', '1', 'Inventario Transitorio Cambio De Mercadería Con Iva', 'Inventario Transitorio Cambio De Mercadería Con Iva', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.01.05', '1', 'Inventario Transitorio Cambio Mercadería Sin Iva', 'Inventario Transitorio Cambio Mercadería Sin Iva', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.01.06', '1', 'Inventario Transitorio Recepciones de Compras', 'Inventario Transitorio Recepciones de Compras', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.03.', '1', 'Inv. De Sum. O Mat. A Ser Consumidos En Proceso', 'Inv. De Sum. O Mat. A Ser Consumidos En Proceso', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.03.01', '1', 'Envases plásticos -Botellas', 'Envases plásticos -Botellas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.03.02', '1', 'Mangas termoencogibles', 'Mangas termoencogibles', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.03.03', '1', 'Sal en grano', 'Sal en grano', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.03.04', '1', 'Tapas para botellas ', 'Tapas para botellas ', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.03.05', '1', 'Fajillas para botellas ', 'Fajillas para botellas ', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.05.', '1', 'Inventarios De Materia Prima', 'Inventarios De Materia Prima', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.07.', '1', 'Importaciones En Transito', 'Importaciones En Transito', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.07.01', '1', 'Importación En Transito No. Amg-Di1722', 'Importación En Transito No. Amg-Di1722', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.07.02', '1', 'Importación En Transito No. Amg-Di180409', 'Importación En Transito No. Amg-Di180409', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.07.03', '1', 'Importación En Transito No. Amg-Di180416', 'Importación En Transito No. Amg-Di180416', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.08.', '1', 'Obras En Construcción', 'Obras En Construcción', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.09.', '1', 'Inventarios Repuestos, Herramientas Y Accesorios', 'Inventarios Repuestos, Herramientas Y Accesorios', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.09.01', '1', 'Inventarios Repuestos, Herramientas Y Accesorios', 'Inventarios Repuestos, Herramientas Y Accesorios', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.10.', '1', 'Producción En Proceso', 'Producción En Proceso', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.10.01', '1', 'Producción En Proceso', 'Producción En Proceso', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.11.', '1', 'Provisión De Inventarios Por Valor Neto De Realización', 'Provisión De Inventarios Por Valor Neto De Realización', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.11.01', '1', 'Provisión De Inventarios Por Valor Neto De Realización', 'Provisión De Inventarios Por Valor Neto De Realización', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.12.', '1', 'Provisión De Inventarios Por Deterioro Físico', 'Provisión De Inventarios Por Deterioro Físico', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.12.01', '1', 'Provisión De Inventarios Por Deterioro Físico', 'Provisión De Inventarios Por Deterioro Físico', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.13.', '1', 'Transferencias Internas', 'Transferencias Internas', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.03.13.01', '1', 'Transferencias Internas Inv. (Cero)', 'Transferencias Internas Inv. (Cero)', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.', '1', 'Servicios Y Otros Pagados Anticipados', 'Servicios Y Otros Pagados Anticipados', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.01.', '1', 'Seguros Pagados Por Anticipado', 'Seguros Pagados Por Anticipado', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.01.01', '1', 'Seguros A', 'Seguros A', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.02.', '1', 'Arriendo Pagados Por Anticipado', 'Arriendo Pagados Por Anticipado', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.02.01', '1', 'Arriendo Pagados Por Anticipado', 'Arriendo Pagados Por Anticipado', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.03.', '1', 'Anticipo A Proveedores', 'Anticipo A Proveedores', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.03.01', '1', 'Anticipo A Laboratorios Negrete ', 'Anticipo A Laboratorios Negrete ', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.03.02', '1', 'Anticipo Proveedor Construcción ', 'Anticipo Proveedor Construcción ', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.03.03', '1', 'Anticipo Otros Proveedores', 'Anticipo Otros Proveedores', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.04.03.04', '1', 'Anticipo Proveedores Gastos Importación', 'Anticipo Proveedores Gastos Importación', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.05.', '1', 'Activos Por Impuestos Corrientes', 'Activos Por Impuestos Corrientes', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.05.01.', '1', 'Crédito Tributario A Favor De La Empresa Iva', 'Crédito Tributario A Favor De La Empresa Iva', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.05.01.01', '1', 'Iva En Compras', 'Iva En Compras', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.05.01.02', '1', 'Retenciones Iva De Clientes', 'Retenciones Iva De Clientes', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.05.02.', '1', 'Crédito Tributario A Favor De La Empresa Renta', 'Crédito Tributario A Favor De La Empresa Renta', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.05.02.01', '1', 'Anticipo Impuesto A La Renta', 'Anticipo Impuesto A La Renta', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.05.02.02', '1', 'Impuestos Retenidos Por Clientes Años Anteriores', 'Impuestos Retenidos Por Clientes Años Anteriores', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.05.02.03', '1', 'Impuestos Retenidos Por Clientes Año Actual', 'Impuestos Retenidos Por Clientes Año Actual', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.1.05.02.04', '1', 'Impuestos A La Renta A Favor Años Anteriores', 'Impuestos A La Renta A Favor Años Anteriores', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.', '1', 'Activo No Corriente', 'Activo No Corriente', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.', '1', 'Propiedad, Planta Y Equipo', 'Propiedad, Planta Y Equipo', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.', '1', 'Costo', 'Costo', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.01', '1', 'Terrenos', 'Terrenos', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.02', '1', 'Edificios', 'Edificios', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.03', '1', 'Construcciones En Curso', 'Construcciones En Curso', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.04', '1', 'Instalaciones', 'Instalaciones', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.05', '1', 'Muebles Y Enseres', 'Muebles Y Enseres', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.06', '1', 'Maquinaria Y Equipo', 'Maquinaria Y Equipo', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.07', '1', 'Naves, Aeronaves, Barcazas Y Similares', 'Naves, Aeronaves, Barcazas Y Similares', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.08', '1', 'Equipos De Computación', 'Equipos De Computación', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.09', '1', 'Vehículos, Equipos De Transporte Y Equipo Caminero Móvil', 'Vehículos, Equipos De Transporte Y Equipo Caminero Móvil', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.10', '1', 'Otras Propiedades, Planta Y Equipo', 'Otras Propiedades, Planta Y Equipo', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.01.11', '1', 'Repuestos Y Herramientas', 'Repuestos Y Herramientas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.', '1', '(-) Depreciación Acumulada Propiedades, Planta Y Equipo', '(-) Depreciación Acumulada Propiedades, Planta Y Equipo', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.02', '1', 'Dep.Acum. Edificios', 'Dep.Acum. Edificios', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.03', '1', 'Dep.Acum. Construcciones En Curso', 'Dep.Acum. Construcciones En Curso', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.04', '1', 'Dep.Acum. Instalaciones', 'Dep.Acum. Instalaciones', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.05', '1', 'Dep.Acum. Muebles Y Enseres', 'Dep.Acum. Muebles Y Enseres', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.06', '1', 'Dep.Acum. Maquinaria Y Equipo', 'Dep.Acum. Maquinaria Y Equipo', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.07', '1', 'Dep.Acum. Naves, Aeronaves, Barcazas Y Similares', 'Dep.Acum. Naves, Aeronaves, Barcazas Y Similares', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.08', '1', 'Dep.Acum. Equipos De Computación', 'Dep.Acum. Equipos De Computación', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.09', '1', 'Dep.Acum. Vehículos, Equipos De Transporte Y Equipo Caminero', 'Dep.Acum. Vehículos, Equipos De Transporte Y Equipo Caminero', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.10', '1', 'Dep.Acum. Otras Propiedades, Planta Y Equipo', 'Dep.Acum. Otras Propiedades, Planta Y Equipo', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.02.11', '1', 'Dep.Acum. Repuestos Y Herramientas', 'Dep.Acum. Repuestos Y Herramientas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.', '1', '(-) Deterioro Acumulado De Propiedades, Planta Y Equipo', '(-) Deterioro Acumulado De Propiedades, Planta Y Equipo', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.01', '1', 'Det.Acum. Terrenos', 'Det.Acum. Terrenos', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.02', '1', 'Det.Acum. Edificios', 'Det.Acum. Edificios', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.03', '1', 'Det.Acum. Construcciones En Curso', 'Det.Acum. Construcciones En Curso', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.04', '1', 'Det.Acum. Instalaciones', 'Det.Acum. Instalaciones', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.05', '1', 'Det.Acum. Muebles Y Enseres', 'Det.Acum. Muebles Y Enseres', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.06', '1', 'Det.Acum. Maquinaria Y Equipo', 'Det.Acum. Maquinaria Y Equipo', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.07', '1', 'Det.Acum. Naves, Aeronaves, Barcazas Y Similares', 'Det.Acum. Naves, Aeronaves, Barcazas Y Similares', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.08', '1', 'Det.Acum. Equipos De Computación', 'Det.Acum. Equipos De Computación', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.09', '1', 'Det.Acum. Vehículos, Equipos De Transporte Y Equipo Caminero', 'Det.Acum. Vehículos, Equipos De Transporte Y Equipo Caminero', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.10', '1', 'Det.Acum. Otras Propiedades,Planta Y Equipo', 'Det.Acum. Otras Propiedades,Planta Y Equipo', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.01.03.11', '1', 'Det.Acum. Repuestos Y Herramientas', 'Det.Acum. Repuestos Y Herramientas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.02.', '1', 'Propiedades De Inversion', 'Propiedades De Inversion', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.02.01.', '1', 'Costo', 'Costo', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.02.01.01', '1', 'Prop.Inversion Terrenos', 'Prop.Inversion Terrenos', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.02.01.02', '1', 'Prop.Inversion Edificios', 'Prop.Inversion Edificios', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.02.02.', '1', '(-)Deterioro Acumulado De Propiedades De Inversion', '(-)Deterioro Acumulado De Propiedades De Inversion', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.02.02.01', '1', 'Det.Acum. Prop.Inversion Terrenos', 'Det.Acum. Prop.Inversion Terrenos', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.02.02.02', '1', 'Det.Acum. Prop.Inversion Edificios', 'Det.Acum. Prop.Inversion Edificios', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.', '1', 'Activo Intangible', 'Activo Intangible', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.01.', '1', 'Costo', 'Costo', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.01.01', '1', 'Plusvalias', 'Plusvalias', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.01.02', '1', 'Marcas, Patentes, Derecho De Llave', 'Marcas, Patentes, Derecho De Llave', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.01.03', '1', 'Software Contable Y Ventas', 'Software Contable Y Ventas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.02.', '1', '(-) Amortizacion Acumalada De Activos Intangibles', '(-) Amortizacion Acumalada De Activos Intangibles', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.02.01', '1', 'Amortiz.Acum. Plusvalias', 'Amortiz.Acum. Plusvalias', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.02.02', '1', 'Amortiz .Acum. Marcas, Patentes, Derecho De Llave,Cuotas', 'Amortiz .Acum. Marcas, Patentes, Derecho De Llave,Cuotas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.03.', '1', '(-) Deterioro Acumulado De Activos Intangibles', '(-) Deterioro Acumulado De Activos Intangibles', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.03.01', '1', 'Det.Acum. Plusvalias', 'Det.Acum. Plusvalias', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.04.03.02', '1', 'Det.Acum. Marcas, Patentes, Derecho De Llave,Cuotas', 'Det.Acum. Marcas, Patentes, Derecho De Llave,Cuotas', 'DET',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),

('1.2.05.', '1', 'Activos Por Impuestos Diferidos', 'Activos Por Impuestos Diferidos', 'MAY',
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
 USER(), 'ACT'),
 
('1.2.05.01', '1', 'Activos Por Impuestos Diferidos', 'Activos Por Impuestos Diferidos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('1.2.06.', '1', 'Activos Financieros No Corrientes', 'Activos Financieros No Corrientes', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('1.2.06.01.', '1', 'Activos Financieros Mantenidos Hasta Su Vencimiento', 'Activos Financieros Mantenidos Hasta Su Vencimiento', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('1.2.06.01.01', '1', 'Depositos A Plazo Banco A', 'Depositos A Plazo Banco A', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.', '2', 'Pasivo', 'Pasivo', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.', '2', 'Pasivo Corriente', 'Pasivo Corriente', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.03.', '2', 'Cuentas Y Documentos Por Pagar', 'Cuentas Y Documentos Por Pagar', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.03.01.', '2', 'Proveedores', 'Proveedores', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.03.01.01', '2', 'Proveedores Locales', 'Proveedores Locales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.03.01.02', '2', 'Proveedores Del Exterior', 'Proveedores Del Exterior', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.03.01.03', '2', 'Transitoria Cruce Proveedores (Siempre Cero)', 'Transitoria Cruce Proveedores (Siempre Cero)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.04.', '2', 'Obligaciones Con Instituciones Financieras', 'Obligaciones Con Instituciones Financieras', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.04.01.', '2', 'Bancos Locales', 'Bancos Locales', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.04.01.01', '2', 'Préstamo Banco Pichincha K 210000.00', 'Préstamo Banco Pichincha K 210000.00', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.04.01.02', '2', 'Préstamo Banco Pichincha K 100000.00', 'Préstamo Banco Pichincha K 100000.00', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.04.02.', '2', 'Bancos Del Exterior', 'Bancos Del Exterior', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.04.02.01', '2', 'Banco A', 'Banco A', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.05.', '2', 'Provisiones', 'Provisiones', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.05.01.', '2', 'Contingencias Laborales', 'Contingencias Laborales', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.05.01.01', '2', 'Contingencias Laborales', 'Contingencias Laborales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.05.02.', '2', 'Contingencias Tributarias', 'Contingencias Tributarias', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.05.02.01', '2', 'Contingencias Tributarias', 'Contingencias Tributarias', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.', '2', 'Otras Obligaciones Corrientes', 'Otras Obligaciones Corrientes', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.', '2', 'Con La Administracion Tributaria', 'Con La Administracion Tributaria', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.', '2', 'Retencion En La Fuente', 'Retencion En La Fuente', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.01', '2', 'Retencion Fuente En Relacion De Dependencia (302)', 'Retencion Fuente En Relacion De Dependencia (302)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.02', '2', 'Honorarios Profesionales 10% (303)', 'Honorarios Profesionales 10% (303)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.03', '2', 'Predomina El Intelecto 8%  (304)', 'Predomina El Intelecto 8%  (304)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.04', '2', 'Predomina Mano De Obra 2% (307)', 'Predomina Mano De Obra 2% (307)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.05', '2', 'Entre Sociedades 2% (308)', 'Entre Sociedades 2% (308)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.06', '2', 'Publicidad Y Comunicacion 1% (309)', 'Publicidad Y Comunicacion 1% (309)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.07', '2', 'Transporte Privado De Pasajeros O Carga 1% (310)', 'Transporte Privado De Pasajeros O Carga 1% (310)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.08', '2', 'Transferencia De Bienes Muebles  1% (312)', 'Transferencia De Bienes Muebles  1% (312)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.09', '2', 'Arriendamiento Mercantil (319)', 'Arriendamiento Mercantil (319)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.10', '2', 'Arrendamiento Bienes Inmuebles 8% (320)', 'Arrendamiento Bienes Inmuebles 8% (320)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.11', '2', 'Seguros Y Reaseguros (Primas Y Cesiones)  (322)', 'Seguros Y Reaseguros (Primas Y Cesiones)  (322)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.12', '2', 'Rendimientos Financieros 2% (323)', 'Rendimientos Financieros 2% (323)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.13', '2', 'Otras Retenciones 1% (343)', 'Otras Retenciones 1% (343)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.14', '2', 'Otras Retenciones 2% (344)', 'Otras Retenciones 2% (344)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.15', '2', 'Otras Retenciones 8% (345)', 'Otras Retenciones 8% (345)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.16', '2', 'Otras Retenciones 25% (343)', 'Otras Retenciones 25% (343)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.17', '2', 'Formulario 103 Por Pagar', 'Formulario 103 Por Pagar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.18', '2', 'Régimen Microempresarial 1.75% (351)', 'Régimen Microempresarial 1.75% (351)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.01.19', '2', 'Otras Retenciones 1.75% (3440)', 'Otras Retenciones 1.75% (3440)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.02.', '2', 'Impuesto Al Valor Agregado', 'Impuesto Al Valor Agregado', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.02.01', '2', 'Iva En Ventas O Servicios', 'Iva En Ventas O Servicios', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.02.02', '2', 'Retencion Del Iva 30% (721)', 'Retencion Del Iva 30% (721)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.02.03', '2', 'Retencion Del Iva 70% (723)', 'Retencion Del Iva 70% (723)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.02.04', '2', 'Retencion Del Iva 100% (725)', 'Retencion Del Iva 100% (725)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.02.05', '2', 'Retencion Del Iva 10%', 'Retencion Del Iva 10%', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.02.06', '2', 'Retencion Del Iva 20%', 'Retencion Del Iva 20%', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.02.07', '2', 'Formulario 104 Iva Por Pagar', 'Formulario 104 Iva Por Pagar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.03.', '2', 'Impuestos Sri Por Liquidar', 'Impuestos Sri Por Liquidar', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.03.01', '2', 'Facilidades De Pa', 'Facilidades De Pa', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.04.', '2', 'Impuesto A Los Consumos Especiales', 'Impuesto A Los Consumos Especiales', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.01.04.01', '2', 'ICE En Ventas', 'ICE En Ventas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.02.', '2', 'Impuesto A La Renta', 'Impuesto A La Renta', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.02.01', '2', 'Impuesto A La Renta Del Ejercicio Por Pagar', 'Impuesto A La Renta Del Ejercicio Por Pagar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.03.', '2', 'Con El Instituto Ecuatoriano De Seguridad Social', 'Con El Instituto Ecuatoriano De Seguridad Social', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.03.01', '2', 'Aportes Personal Iess', 'Aportes Personal Iess', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.03.02', '2', 'Prestamos Quirografarios Iess', 'Prestamos Quirografarios Iess', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.03.03', '2', 'Fondos De Reserva Iess', 'Fondos De Reserva Iess', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.03.04', '2', 'Aporte Patronal Iess', 'Aporte Patronal Iess', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.03.05', '2', 'Prestamos Hipotecarios Iess', 'Prestamos Hipotecarios Iess', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.03.06', '2', 'Extension Conyugal Por Pagar', 'Extension Conyugal Por Pagar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.04.', '2', 'Por Sueldos Beneficios De Ley A Empleados', 'Por Sueldos Beneficios De Ley A Empleados', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.04.01', '2', 'Sueldos', 'Sueldos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.04.02', '2', 'Decimo Tercer Sueldo', 'Decimo Tercer Sueldo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.04.03', '2', 'Decimo Cuarto Sueldo', 'Decimo Cuarto Sueldo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.04.04', '2', 'Vacaciones Provision', 'Vacaciones Provision', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.04.05', '2', 'Fondos De Reserva Empleados', 'Fondos De Reserva Empleados', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.04.06', '2', 'Liquidaciones Haberes Por Pagar', 'Liquidaciones Haberes Por Pagar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.05.', '2', 'Participacion Trabajadores Por Pagar', 'Participacion Trabajadores Por Pagar', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.05.01', '2', 'Participacion Trabajadores Por Pagar Del Ejercicio', 'Participacion Trabajadores Por Pagar Del Ejercicio', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.07.06.', '2', 'Dividendos Por Pagar', 'Dividendos Por Pagar', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.08.', '2', 'Cuentas Por Pagar Relacionadas', 'Cuentas Por Pagar Relacionadas', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.08.01.', '2', 'Proveedor Relacionado', 'Proveedor Relacionado', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.08.02.', '2', 'Prestamos Relacionadas', 'Prestamos Relacionadas', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.08.02.01', '2', 'Prestamos Relacionadas', 'Prestamos Relacionadas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.', '2', 'Otros Pasivos Financieros', 'Otros Pasivos Financieros', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.01.', '2', 'Comisiones', 'Comisiones', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.01.01', '2', 'Señor A', 'Señor A', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.02.', '2', 'Otras Cuentas Por Pagar', 'Otras Cuentas Por Pagar', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.02.01', '2', 'Otras Cuentas Por Pagar', 'Otras Cuentas Por Pagar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.02.02', '2', 'Anticipos En Ventas De Propiedad, Planta Y Equipo', 'Anticipos En Ventas De Propiedad, Planta Y Equipo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.02.03', '2', 'Arriendos Por Pagar', 'Arriendos Por Pagar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.02.04', '2', 'Depositos Por Identificar', 'Depositos Por Identificar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.02.05', '2', 'Comision Tarjetas (Transitoria)', 'Comision Tarjetas (Transitoria)', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.02.99', '2', 'Otras Cuentas Por Pagar Propinas', 'Otras Cuentas Por Pagar Propinas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.03.', '2', 'Tarjetas De Credito', 'Tarjetas De Credito', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.03.01', '2', 'Tarjeta A', 'Tarjeta A', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.03.02', '2', 'Tarjeta B', 'Tarjeta B', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.04.', '2', 'Prestamos De Terceros', 'Prestamos De Terceros', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.04.01', '2', 'Prestamo Elva Elizalde', 'Prestamo Elva Elizalde', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.09.04.02', '2', 'Préstamo Por Pagar Silvia Pantoja', 'Préstamo Por Pagar Silvia Pantoja', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.10.', '2', 'Anticipo De Clientes', 'Anticipo De Clientes', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.10.01.', '2', 'Anticipo De Clientes', 'Anticipo De Clientes', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.1.10.01.01', '2', 'Anticipo De Cliente Cobro Cartera ', 'Anticipo De Cliente Cobro Cartera ', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.', '2', 'Pasivo No Corriente', 'Pasivo No Corriente', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.02.', '2', 'Cuentas Y Documentos Por Pagar', 'Cuentas Y Documentos Por Pagar', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),

('2.2.02.01.', '2', 'Proveedores Lar Plazo', 'Proveedores Lar Plazo', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.02.01.01', '2', 'Proveedores Lar Plazo Locales', 'Proveedores Lar Plazo Locales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.02.01.02', '2', 'Proveedores Lar Plazo Del Exterior', 'Proveedores Lar Plazo Del Exterior', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.03.', '2', 'Obligaciones Con Instituciones Financieras Lar Plazo', 'Obligaciones Con Instituciones Financieras Lar Plazo', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.03.01.', '2', 'Prestamos Bcos Nacionales', 'Prestamos Bcos Nacionales', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.03.01.01', '2', 'Prestamos Banco Pichicnha', 'Prestamos Banco Pichicnha', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.03.02.', '2', 'Prestamos Bcos Del Exterior', 'Prestamos Bcos Del Exterior', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.03.02.01', '2', 'Banco A', 'Banco A', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.04.', '2', 'Cuentas Por Pagar Relacionadas Lar Plazo', 'Cuentas Por Pagar Relacionadas Lar Plazo', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.04.01.', '2', 'Proveedor Relacionado Lar Plazo', 'Proveedor Relacionado Lar Plazo', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.04.01.01', '2', 'Empresa A', 'Empresa A', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.04.02.', '2', 'Prestamos Relacionadas Lar Plazo', 'Prestamos Relacionadas Lar Plazo', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.04.02.01', '2', 'Pasivo No Corriente - Juan Pantoja', 'Pasivo No Corriente - Juan Pantoja', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.07.', '2', 'Provisiones Por Bebeficios A Empleados', 'Provisiones Por Bebeficios A Empleados', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.07.01.', '2', 'Provisiones Por Bebeficios A Empleados', 'Provisiones Por Bebeficios A Empleados', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.07.01.01', '2', 'Jubilacion Patronal', 'Jubilacion Patronal', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.07.01.02', '2', 'Jubilacion Por Desahucio', 'Jubilacion Por Desahucio', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.09.', '2', 'Pasivo Diferido', 'Pasivo Diferido', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.09.01', '2', 'Ingresos Diferidos', 'Ingresos Diferidos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.09.02', '2', 'Pasivos Por Impuestos Diferidos', 'Pasivos Por Impuestos Diferidos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('2.2.10.', '2', 'Otros Pasivos Lar Plazo No Corrientes', 'Otros Pasivos Lar Plazo No Corrientes', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.', '3', 'Patrimonio Neto', 'Patrimonio Neto', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.1.', '3', 'Capital', 'Capital', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.1.01.', '3', 'Capital Suscrito O Asignando', 'Capital Suscrito O Asignando', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.1.01.01', '3', 'Capital Suscrito O Asignando', 'Capital Suscrito O Asignando', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.1.01.02', '3', 'Socio B', 'Socio B', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.2.', '3', 'Aportes De Socios O Accionistas Para Futura Capitalizacion', 'Aportes De Socios O Accionistas Para Futura Capitalizacion', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.2.01.', '3', 'Aportes De Socios O Accionistas Para Futura Capitalizacion', 'Aportes De Socios O Accionistas Para Futura Capitalizacion', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.2.01.01', '3', 'Aportes De Socios O Accionistas Para Futura Capitalizacion', 'Aportes De Socios O Accionistas Para Futura Capitalizacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.2.01.02', '3', 'Socio B', 'Socio B', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.4.', '3', 'Reservas', 'Reservas', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.4.01.', '3', 'Reservas', 'Reservas', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.4.01.01', '3', 'Reserva Legal', 'Reserva Legal', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.4.01.02', '3', 'Reserva Facultativa Y Estatutaria', 'Reserva Facultativa Y Estatutaria', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.4.01.03', '3', 'Reserva De Capital', 'Reserva De Capital', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.4.01.04', '3', 'Otras Reservas', 'Otras Reservas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.5.', '3', 'Otros Resultados Integrales', 'Otros Resultados Integrales', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.5.01.', '3', 'Otros Resultados Integrales', 'Otros Resultados Integrales', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.5.01.01', '3', 'Superavit Por Revaluacion De Act. Disponibles Para La Venta', 'Superavit Por Revaluacion De Act. Disponibles Para La Venta', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.5.01.02', '3', 'Superavit Por Revaluacion De Propiedades, Planta Y Equipo', 'Superavit Por Revaluacion De Propiedades, Planta Y Equipo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.5.01.03', '3', 'Superavit Por Revaluacion De Activos Intangibles', 'Superavit Por Revaluacion De Activos Intangibles', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.5.01.04', '3', 'Otros Superavit Por Revaluacion', 'Otros Superavit Por Revaluacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.6.', '3', 'Resultados Acumulados', 'Resultados Acumulados', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.6.01.', '3', 'Ganancias Acumuladas', 'Ganancias Acumuladas', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.6.01.01', '3', 'Ganancias Acumuladas Año N', 'Ganancias Acumuladas Año N', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.6.02.', '3', '(-)Perdidas Acumuladas', '(-)Perdidas Acumuladas', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.6.02.01', '3', '(-)Perdidas Acumuladas Año N', '(-)Perdidas Acumuladas Año N', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.6.03.', '3', 'Result. Acum. Provenientes De La Adopcion Por Primera Vez', 'Result. Acum. Provenientes De La Adopcion Por Primera Vez', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.6.03.01', '3', 'Utilidad / Perdida Por Conversion De Niifs', 'Utilidad / Perdida Por Conversion De Niifs', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.7.', '3', 'Resultados Del Ejercicio', 'Resultados Del Ejercicio', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.7.01.', '3', 'Resultados Del Ejercicio', 'Resultados Del Ejercicio', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.7.01.01', '3', 'Ganancia Neta Del Periodo', 'Ganancia Neta Del Periodo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('3.7.01.02', '3', '(-) Perdida Neta Del Periodo', '(-) Perdida Neta Del Periodo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.', '4', 'Ingresos', 'Ingresos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.', '4', 'Ingresos De Actividades Ordinarias', 'Ingresos De Actividades Ordinarias', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.01.', '4', 'Venta De Bienes', 'Venta De Bienes', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.01.01', '4', 'Ventas Bienes Con Iva', 'Ventas Bienes Con Iva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.01.02', '4', 'Ventas Bienes Sin Iva', 'Ventas Bienes Sin Iva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.02.', '4', '(-) Descuentos En Ventas', '(-) Descuentos En Ventas', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.02.01', '4', 'Descuentos En Ventas Con Iva', 'Descuentos En Ventas Con Iva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.02.02', '4', 'Descuentos En Ventas Sin Iva', 'Descuentos En Ventas Sin Iva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.02.04', '4', 'Otros Descuentos Ventas', 'Otros Descuentos Ventas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.03.', '4', '(-) Devoluciones En Ventas', '(-) Devoluciones En Ventas', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.03.01', '4', 'Devolucion En Ventas Con Iva', 'Devolucion En Ventas Con Iva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.1.03.02', '4', 'Devolucion En Ventas Sin Iva', 'Devolucion En Ventas Sin Iva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.2.', '4', 'Otros Ingresos', 'Otros Ingresos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.2.01.', '4', 'Otros Ingresos', 'Otros Ingresos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.2.01.01', '4', 'Utilidad En Venta De Activos Fijos', 'Utilidad En Venta De Activos Fijos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.2.01.02', '4', 'Ingreso Por Descuento En Ventas', 'Ingreso Por Descuento En Ventas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.2.01.03', '4', 'Otros  Ingresos', 'Otros  Ingresos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.2.01.04', '4', 'Otros Ingresos Por Facturacion', 'Otros Ingresos Por Facturacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.2.01.05', '4', 'Otros Ingresos Sobrantes Caja', 'Otros Ingresos Sobrantes Caja', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('4.2.01.06', '4', 'Venta Activos Fijos', 'Venta Activos Fijos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.', '5', 'Egresos', 'Egresos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.', '5', 'Costos De Ventas Y Produccion', 'Costos De Ventas Y Produccion', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.', '5', 'Materiales Utilizados O Productos Vendidos', 'Materiales Utilizados O Productos Vendidos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.01.', '5', 'Materiales Utilizados O Productos Vendidos', 'Materiales Utilizados O Productos Vendidos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.01.01', '5', 'Costo De Ventas Mercaderia Con Iva', 'Costo De Ventas Mercaderia Con Iva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.01.02', '5', 'Costo De Ventas Mercaderia Sin Iva', 'Costo De Ventas Mercaderia Sin Iva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.01.03', '5', 'Descuento En Compras', 'Descuento En Compras', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.01.04', '5', 'Descuento Por Pronto Pa', 'Descuento Por Pronto Pa', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.01.05', '5', 'Otros Descuentos Compra', 'Otros Descuentos Compra', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.02.', '5', 'Gasto Por Cantidades Anormales En El Proceso De Produccion', 'Gasto Por Cantidades Anormales En El Proceso De Produccion', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.02.01', '5', 'Gasto Por Cantidades Anormales De Mano De Obra', 'Gasto Por Cantidades Anormales De Mano De Obra', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.01.02.02', '5', 'Gasto Por Cantidades Anormales De Materiales', 'Gasto Por Cantidades Anormales De Materiales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.02.', '5', 'Materia Prima Consumida', 'Materia Prima Consumida', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.02.01.', '5', 'Materia Prima Consumida', 'Materia Prima Consumida', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.02.01.01', '5', 'Materia Prima Consumida', 'Materia Prima Consumida', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.02.99.', '5', 'Mp - Cta. Cierre Materia Prima Consumida', 'Mp - Cta. Cierre Materia Prima Consumida', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.02.99.99', '5', 'Mp -  Cta. Cierre Materia Prima Consumida', 'Mp -  Cta. Cierre Materia Prima Consumida', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.', '5', 'Mano De Obra Directa', 'Mano De Obra Directa', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.', '5', 'Mod - Sueldos Y Beneficios Sociales', 'Mod - Sueldos Y Beneficios Sociales', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.01.', '5', 'Mod - Sueldos Y Demas Remun. Materia Gravada Iess', 'Mod - Sueldos Y Demas Remun. Materia Gravada Iess', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.01.01', '5', 'Mod - Sueldos Unificados', 'Mod - Sueldos Unificados', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.01.02', '5', 'Mod - Horas Extras', 'Mod - Horas Extras', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.01.03', '5', 'Mod - Comisiones Empleados', 'Mod - Comisiones Empleados', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.01.04', '5', 'Mod - Bonos Por Desempeño', 'Mod - Bonos Por Desempeño', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.01.05', '5', 'Mod - Participacion Trabajadores', 'Mod - Participacion Trabajadores', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.02.', '5', 'Mod - Aportes A La Seguridad Social (Incluido F. De Reserva)', 'Mod - Aportes A La Seguridad Social (Incluido F. De Reserva)', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.02.01', '5', 'Mod - Aporte Patronal', 'Mod - Aporte Patronal', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),

('5.1.03.01.02.02', '5', 'Mod - Fondos De Reserva', 'Mod - Fondos De Reserva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.03.', '5', 'Mod - Benef. Soc. E Indem.', 'Mod - Beneficios Sociales E Indemnizaciones', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.03.01', '5', 'Mod - Decimo Tercer Sueldo', 'Mod - Decimo Tercer Sueldo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.03.02', '5', 'Mod - Decimo Cuarto Sueldo', 'Mod - Decimo Cuarto Sueldo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.03.03', '5', 'Mod - Vacaciones', 'Mod - Vacaciones', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.03.04', '5', 'Mod - Remuneracion Adic.', 'Mod - Remuneracion Adicionales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.03.05', '5', 'Mod - Indemnizaciones Lab.', 'Mod - Indemnizaciones Laborables', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.03.06', '5', 'Mod - Movilizacion', 'Mod - Movilizacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.01.03.07', '5', 'Mod - Vacaciones Por Pagar', 'Mod - Vacaciones Por Pagar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.02.', '5', 'Mod - Gasto Pl. Benef. Empl', 'Mod - Gasto Planes De Beneficios A Empleados', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.02.01.', '5', 'Mod - Gasto Jub. Pat. Y Des.', 'Mod - Gasto Jubilacion Patronal Y Desahucio', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.02.01.01', '5', 'Mod - Gasto Jubilacion Patr', 'Mod - Gasto Jubilacion Patronal', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.02.01.02', '5', 'Mod - Gasto Desahucio', 'Mod - Gasto Desahucio', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.03.', '5', 'Mod - Cta Cierre Mano Obra', 'Mod - Cta De Cierre De Mano De Obra', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.03.99.', '5', 'Mod - Cta Cierre Mano Obra', 'Mod - Cta De Cierre De Mano De Obra', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.03.03.99.99', '5', 'Mod - Cta Cierre Mano Obra', 'Mod - Cta De Cierre De Mano De Obra', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.', '5', 'Otros CIF', 'Otros Costos Indirectos De Fabricacion', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.01.', '5', 'Cif - Deprec. Planta Y Eq.', 'Cif - Depreciacione Planta Y Equipo', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.01.01', '5', 'Cif - Deprec. Edificios', 'Cif - Deprec. Edificios', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.01.02', '5', 'Cif - Deprec. Instalaciones', 'Cif - Deprec. Instalaciones', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.01.03', '5', 'Cif - Deprec. Muebles Y Ens.', 'Cif - Deprec. Muebles Y Enseres', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.01.04', '5', 'Cif - Deprec. Maq. Y Equipo', 'Cif - Deprec. Maquinaria Y Equipo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.01.05', '5', 'Cif - Deprec. Eq. Comput.', 'Cif - Deprec. Equipos De Computacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.01.06', '5', 'Cif - Vehic.,Eq. Transp.', 'Cif - Deprec. Vehiculos,Equipos De Transporte Y Equipo Camin', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.01.07', '5', 'Cif - Deprec. Eq. Logistica', 'Cif - Deprec. Equipo De Logistica', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.03.', '5', 'Cif - Deterioro', 'Cif - Deterioro', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.03.01', '5', 'Cif - Det. Prop.,Planta Y Eq', 'Cif - Deterioro Propiedades, Planta Y Equipo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.03.02', '5', 'Cif - Deterioro Inventarios', 'Cif - Deterioro Inventarios', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.03.03', '5', 'Cif - Det. Instrumentos Fin.', 'Cif - Deterioro Instrumentos Financieros', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.03.04', '5', 'Cif - Deterioro Intangibles', 'Cif - Deterioro Intangibles', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.03.05', '5', 'Cif - Det. Ctas. Por Cobrar', 'Cif - Deterioro Cuentas Por Cobrar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.03.06', '5', 'Cif - Deterioro Otros Act.', 'Cif - Deterioro Otros Activos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.04.', '5', 'Cif - Efecto VNR Invent.', 'Cif - Efecto Valor Neto De Realizacion Inventarios', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.04.01', '5', 'Cif - Ajuste VNR', 'Cif - Ajuste Valor Neto De Realizacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.06.', '5', 'Cif - Mant. Y Reparaciones', 'Cif - Mantenimiento Y Reparaciones', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.06.01', '5', 'Cif - Mant. Eq. Computacion', 'Cif - Mant. Y Rep. De Equipos De Computacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.06.02', '5', 'Cif - Mant. Eq. Oficina', 'Cif - Mant. Y Rep. De Equipos De Oficina', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.06.03', '5', 'Cif - Mant. Y Rep. Vehiculos', 'Cif - Mant. Y Rep. De Vehiculos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.07.', '5', 'Cif - Suministros Mat. Y Rep.', 'Cif - Suministros Materiales Y Repuestos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.07.01', '5', 'Cif - Material De Embalaje', 'Cif - Material De Embalaje', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.07.02', '5', 'Cif - Repuestos De Vehiculos', 'Cif - Repuestos De Vehiculos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.07.03', '5', 'Cif - Repuestos De Maquinaria', 'Cif - Repuestos De Maquinaria', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.07.04', '5', 'Cif - Mant. Sist. electrico', 'Cif-Mantenimiento sistema eléctrico', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.08.', '5', 'Cif - Otros Costos Prod.', 'Cif - Otros Costos De Produccion', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.08.01', '5', 'Cif - Serv. Transp. Mat. Prima', 'Cif - Servicio de Transporte de Materia Prima', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.08.02', '5', 'Costo de Cireles', 'Costo de Cireles', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.99.', '5', 'Cf - Cta Cierre Gtos. Ind.', 'Cf - Cta De Cierre De Gastos Ind. De Fabricacion', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.1.04.99.99', '5', 'Cf - Cta Cierre Gtos. Ind.', 'Cf - Cta De Cierre De Gastos Ind. De Fabricacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.', '5', 'Gastos', 'Gastos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.', '5', 'Gastos De Ventas', 'Gastos De Ventas', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),

('5.2.01.01.', '5', 'Gv - Sueldos Y Demun. Gravada', 'Gv - Sueldos Y Demas Remun. Materia Gravada Iess', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.01.01', '5', 'Gv - Sueldos Unificados', 'Gv - Sueldos Unificados', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.01.02', '5', 'Gv - Horas Extras', 'Gv - Horas Extras', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.01.03', '5', 'Gv - Comisiones Empleados', 'Gv - Comisiones Empleados', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.01.04', '5', 'Gv - Bonos Por Desempeño', 'Gv - Bonos Por Desempeño', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.01.15', '5', 'Gv - 15% Part. Trabajadores', 'Gv - 15% Participacion Trabajadores', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.02.', '5', 'Gv - Aportes Seguridad Social', 'Gv - Aportes A La Seguridad Social (Incluido Fondo De Reserv', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.02.01', '5', 'Gv - Aporte Patronal', 'Gv - Aporte Patronal', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.02.02', '5', 'Gv - Fondos De Reserva', 'Gv - Fondos De Reserva', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.03.', '5', 'Gv - Benef. Soc. E Indem.', 'Gv - Beneficios Sociales E Indemnizaciones', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.03.01', '5', 'Gv - Decimo Tercer Sueldo', 'Gv - Decimo Tercer Sueldo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.03.02', '5', 'Gv - Decimo Cuarto Sueldo', 'Gv - Decimo Cuarto Sueldo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.03.03', '5', 'Gv - Vacaciones', 'Gv - Vacaciones', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.03.04', '5', 'Gv - Remuneracion Adic.', 'Gv - Remuneracion Adicionales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.03.05', '5', 'Gv - Indemnizaciones Lab.', 'Gv - Indemnizaciones Laborables', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.03.06', '5', 'Gv - Movilizacion', 'Gv - Movilizacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.03.07', '5', 'Gv - Vacaciones Por Pagar', 'Gv - Vacaciones Por Pagar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.04.', '5', 'Gv - Gasto Pl. Benef. Empl.', 'Gv - Gasto Planes De Beneficios A Empleados', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.04.01', '5', 'Gv - Gasto Jubilacion Patr', 'Gv - Gasto Jubilacion Patronal', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.04.02', '5', 'Gv - Gasto Desahucio', 'Gv - Gasto Desahucio', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.05.', '5', 'Gv - Honor., Comis. Y Dietas', 'Gv - Honorarios, Comisiones Y Dietas Personas Naturales', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.05.01', '5', 'Gv - Servicios Legales', 'Gv - Servicios Legales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.05.02', '5', 'Gv - Servicios Profesionales', 'Gv - Servicios Profesionales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.06.', '5', 'Gv - Remun. Otros Autonomos', 'Gv - Remuneraciones A Otros Trabajadores Autonomos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.06.01', '5', 'Gv - Servicios Ocasionales', 'Gv - Servicios Ocasionales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.06.02', '5', 'Gv - Serv. Impresion E Imp.', 'Gv - Servicios De Impresion E Imprenta', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.06.03', '5', 'Gv - Avaluos', 'Gv - Avaluos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.08.', '5', 'Gv - Mant. Y Reparaciones', 'Gv - Mantenimiento Y Reparaciones', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.08.01', '5', 'Gv - Mant. Eq. Computacion', 'Gv - Mant. Y Rep. De Equipos De Computacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.08.02', '5', 'Gv - Mant. Eq. Oficina', 'Gv - Mant. Y Rep. De Equipos De Oficina', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.08.03', '5', 'Gv - Mant. Y Rep. Vehiculos', 'Gv - Mant. Y Rep. De Vehiculos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.08.04', '5', 'Gv - Mant. Inst. Telefonicas', 'Gv - Mant. Y Rep. De Instalaciones Telefonicas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.09.', '5', 'Gv - Arrendamiento Operativo', 'Gv - Arrendamiento Operativo', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.09.01', '5', 'Gv - Arrendamiento De Oficina', 'Gv - Arrendamiento De Oficina', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.10.', '5', 'Gv - Comisiones', 'Gv - Comisiones', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.10.01', '5', 'Gv - Com. A Vendedores Ext.', 'Gv - Comisiones A Vendedores Externos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.11.', '5', 'Gv - Promocion Y Publicidad', 'Gv - Promocion Y Publicidad', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.11.01', '5', 'Gv - Ferias', 'Gv - Ferias', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.11.02', '5', 'Gv - Servicios De Publicidad', 'Gv - Servicios De Publicidad', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.11.03', '5', 'Gv - Publ. Y Anun. En Prensa', 'Gv - Publicidad Y Anuncios En Prensa', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.12.', '5', 'Gv - Combustibles Y Lubr.', 'Gv - Combustibles Y Lubricantes', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.12.01', '5', 'Gv - Combustibles De Veh.', 'Gv - Combustibles De Vehiculos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.12.02', '5', 'Gv - Lubricantes', 'Gv - Lubricantes', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.14.', '5', 'Gv - Seguros Y Reaseguros', 'Gv - Seguros Y Reaseguros (Primas Y Cesiones)', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.14.01', '5', 'Gv - Seguros De Vida', 'Gv - Seguros De Vida', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.14.02', '5', 'Gv - Seguros Generales', 'Gv - Seguros Generales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.14.03', '5', 'Gv - Asistencia Medica', 'Gv - Asistencia Medica', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.15.', '5', 'Gv - Transporte', 'Gv - Transporte', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.15.01', '5', 'Gv - Transporte De Personal', 'Gv - Transporte De Personal', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.15.02', '5', 'Gv - Transporte De Carga', 'Gv - Transporte De Carga', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),

('5.2.01.16.', '5', 'Gv - Gastos De Gestion', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.16.01', '5', 'Gv - Refrigerios A Empleados', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.16.02', '5', 'Gv - Atencion A Clientes / Proveedores', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.16.03', '5', 'Gv - Gasto Restaurantes', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.16.04', '5', 'Gv - Agasajo Navideño', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.17.', '5', 'Gv - Gastos De Viajes', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.17.01', '5', 'Gv - Pasajes Aereos', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.17.02', '5', 'Gv - Hoteles', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.17.03', '5', 'Gv - Alimentacion', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.17.04', '5', 'Gv - Movilizacion En Viajes', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.18.', '5', 'Gv - Agua, Energia, Luz Y Telecomunicaciones', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.18.01', '5', 'Gv - Energia Electrica', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.18.02', '5', 'Gv - Telefonia Celular', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.18.03', '5', 'Gv - Telefonia Fija', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.18.04', '5', 'Gv - Servicios De Internet', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.18.05', '5', 'Gv - Agua', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.19.', '5', 'Gv - Notarios Y Registradores De La Propiedad Y Mercantiles', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.19.01', '5', 'Gv - Notarios', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.19.02', '5', 'Gv - Registradores De La Propiedad Y Mercantiles', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.20.', '5', 'Gv - Impuestos, Contribuciones Y Otros', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.20.01', '5', 'Gv - Gasto Impuesto A La Renta', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.20.02', '5', 'Gv - Gasto Iva', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.20.03', '5', 'Gv - Municipales', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.20.04', '5', 'Gv - Camara De Comercio', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.20.05', '5', 'Gv - Contribucion Superintendencia De Compañias', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.20.06', '5', 'Gv - Intereses Mora Y Multa', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.20.07', '5', 'Gv - Impuestos Salida De Divisas', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.21.', '5', 'Gv - Depreciaciones', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.21.01', '5', 'Gv - Deprec. Edificios', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.21.02', '5', 'Gv - Deprec. Instalaciones', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.21.03', '5', 'Gv - Deprec. Muebles Y Enseres', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.21.04', '5', 'Gv - Deprec. Maquinaria Y Equipo', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.21.05', '5', 'Gv - Deprec. Equipos De Computacion', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.21.06', '5', 'Gv - Deprec. Vehiculos,Equipos De Transporte Y Equipo Camine', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.21.07', '5', 'Gv - Deprec. Equipo De Logistica', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.22.', '5', 'Gv - Amortizaciones', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.22.01', '5', 'Gv - Gastos Amortiz  Plusvalias', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.22.02', '5', 'Gv - Gasto Amort.Iz. Marcas, Patentes, Derecho De Llave', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.23.', '5', 'Gv - Deterioro', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.23.01', '5', 'Gv - Deterioro Propiedades, Planta Y Equipo', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.23.02', '5', 'Gv - Deterioro Inventarios', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.23.03', '5', 'Gv - Deterioro Instrumentos Financieros', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.23.04', '5', 'Gv - Deterioro Intangibles', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.23.05', '5', 'Gv - Deterioro Cuentas Por Cobrar', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.23.06', '5', 'Gv - Deterioro Otros Activos', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.', '5', 'Gv - Otros  Gastos', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.01', '5', 'Gv - Suministros De Aseo Y Limpieza', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.02', '5', 'Gv - Suministros Y Materiales', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.04', '5', 'Gv - Comisiones Tarjetas De Credito', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.05', '5', 'Gv - Capacitacion Y Seminarios', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.07', '5', 'Gv - Seguridad', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.09', '5', 'Gv - Suscripciones', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.11', '5', 'Gv - Atencion Empleados', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.12', '5', 'Gv - Gastos Retenciones Asumidas', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.13', '5', 'Gv - Donaciones', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.14', '5', 'Gv - Uniformes', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.2.01.27.15', '5', 'Gv - Inventario Dañado U Obsoleto', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.', '5', 'Gastos Adminitrativos', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.', '5', 'Ga - Gastos Administrativos', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.01.', '5', 'Ga - Sueldos Y Demas Remun. Materia Gravada Iess', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.01.01', '5', 'Ga - Sueldos Unificados', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.01.02', '5', 'Ga - Horas Extras', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.01.03', '5', 'Ga - Comisiones Empleados', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.01.04', '5', 'Ga - Bonos Por Desempeño', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.01.05', '5', 'Ga - Bonos Empleados No Deducibles', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.01.15', '5', 'Ga - 15% Participacion Trabajadores', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.02.', '5', 'Ga - Aportes A La Seguridad Social (Incluido Fondo De Reserv', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.02.01', '5', 'Ga - Aporte Patronal', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.02.02', '5', 'Ga - Fondos De Reserva', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.02.03', '5', 'Ga - Extension Conyugal', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.03.', '5', 'Ga - Beneficios Sociales E Indemnizaciones', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.03.01', '5', 'Ga - Decimo Tercer Sueldo', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.03.02', '5', 'Ga - Decimo Cuarto Sueldo', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.03.03', '5', 'Ga - Vacaciones', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.03.04', '5', 'Ga - Remuneracion Adicionales', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.03.05', '5', 'Ga - Indemnizaciones Laborables', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.03.06', '5', 'Ga - Movilizacion', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.03.07', '5', 'Ga - Vacaciones Por Pagar', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.04.', '5', 'Ga - Gasto Planes De Beneficios A Empleados', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.04.01', '5', 'Ga - Gasto Jubilacion Patronal', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.04.02', '5', 'Ga - Gasto Desahucio', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.05.', '5', 'Ga - Honorarios, Comisiones Y Dietas Personas Naturales', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.05.01', '5', 'Ga - Servicios Legales', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.05.02', '5', 'Ga - Servicios Profesionales', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.06.', '5', 'Ga - Remuneraciones A Otros Trabajadores Autonomos', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.06.01', '5', 'Ga - Servicios Ocasionales', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.06.02', '5', 'Ga - Servicios De Impresion E Imprenta', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.06.03', '5', 'Ga - Análisis de laboratorio y  Permisos ', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.06.04', '5', 'Ga Servicios De Redes Sociales', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.06.05', '5', 'Ga - Servicios Seguridad Industrial', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.08.', '5', 'Ga - Mantenimiento Y Reparaciones', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.08.01', '5', 'Ga - Mant. Y Rep. De Equipos De Computacion', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.08.02', '5', 'Ga - Mant. Y Rep. De Equipos De Oficina', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.08.03', '5', 'Ga - Mant. Y Rep. De Vehiculos', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.08.04', '5', 'Ga - Mant. Y Rep. De  Instalaciones Telefonicas', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.08.05', '5', 'Ga - Mantenimiento Instalaciones', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.09.', '5', 'Ga - Arrendamiento Operativo', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.09.01', '5', 'Ga - Arrendamiento De Oficina', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.10.', '5', 'Ga - Comisiones', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.10.01', '5', 'Ga - Comisiones A Vendedores Externos', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.11.', '5', 'Ga - Promocion Y Publicidad', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.11.01', '5', 'Ga - Ferias', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.11.02', '5', 'Ga - Servicios De Publicidad', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.11.03', '5', 'Ga - Publicidad Y Anuncios En Prensa', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.12.', '5', 'Ga - Combustibles Y Lubricantes', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.12.01', '5', 'Ga - Combustibles De Vehiculos', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.12.02', '5', 'Ga - Lubricantes', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.14.', '5', 'Ga - Seguros Y Reaseguros (Primas Y Cesiones)', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.14.01', '5', 'Ga - Seguros De Vida', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.14.02', '5', 'Ga - Seguros Generales', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.14.03', '5', 'Ga - Asistencia Medica', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.15.', '5', 'Ga - Transporte', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.15.01', '5', 'Ga - Transporte De Personal', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.15.02', '5', 'Ga - Transporte De Encomienda', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.16.', '5', 'Ga - Gastos De Gestion', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.16.01', '5', 'Ga - Refrigerios A Empleados', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.16.02', '5', 'Ga - Atencion A Clientes/Proveedores', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.16.03', '5', 'Ga - Gasto Restaurantes, Alimentacion Y Refrigerio', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.16.04', '5', 'Ga - Agasajo Navideño', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.16.05', '5', 'Ga - Atencion Clientes', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.17.', '5', 'Ga - Gastos De Viajes', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.17.01', '5', 'Ga - Pasajes Aereos', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.17.02', '5', 'Ga - Hoteles', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.17.03', '5', 'Ga - Alimentacion Y Refrigerio', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.17.04', '5', 'Ga - Movilizacion En Viajes', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.17.05', '5', 'Ga- Otros Gastos De Viajes', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.18.', '5', 'Ga - Agua, Energia, Luz Y Telecomunicaciones', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.18.01', '5', 'Ga - Energia Electrica', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.18.02', '5', 'Ga - Telefonia Celular', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.18.03', '5', 'Ga - Telefonia Fija', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.18.04', '5', 'Ga - Servicios De Internet', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.18.05', '5', 'Ga - Agua', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.19.', '5', 'Ga - Notarios Y Registradores De La Propiedad Y Mercantiles', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.19.01', '5', 'Ga - Notarios', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.19.02', '5', 'Ga - Registradores De La Propiedad Y Mercantiles', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.', '5', 'Ga - Impuestos, Contribuciones Y Otros', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.01', '5', 'Ga - Gasto Impuesto A La Renta', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.02', '5', 'Ga - Gasto Iva', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.03', '5', 'Ga - Patente Municipal', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.04', '5', 'Ga - Camara De Comercio', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.05', '5', 'Ga - Contribucion Superintendencia De Compañias', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.06', '5', 'Ga - Intereses Mora Y Multa', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.07', '5', 'Ga - Impuestos Salida De Divisas', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.08', '5', 'Ga- Impuesto Consumos Especiales Ice', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.09', '5', 'Ga- Retenciones Asumidas', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.20.10', '5', 'Ga- 1.5 Por Mil ', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.21.', '5', 'Ga - Depreciaciones', '', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.21.01', '5', 'Ga - Deprec. Edificios', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.21.02', '5', 'Ga - Deprec. Instalaciones', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.21.03', '5', 'Ga - Deprec. Muebles Y Enseres', '', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),

('5.3.01.21.04', '5', 'Ga - Deprec. Maquinaria', 'Ga - Deprec. Maquinaria Y Equipo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.21.05', '5', 'Ga - Deprec. Equipos De C', 'Ga - Deprec. Equipos De Computacion', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.21.06', '5', 'Ga - Deprec. Vehiculos,Eq', 'Ga - Deprec. Vehiculos,Equipos De Transporte Y Equipo Camine', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.21.07', '5', 'Ga - Deprec. Equipo De Lo', 'Ga - Deprec. Equipo De Logistica', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.22.', '5', 'Ga - Amortizaciones', 'Ga - Amortizaciones', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.22.01', '5', 'Ga - Gastos Amortiz Plusv', 'Ga - Gastos Amortiz Plusvalias', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.22.02', '5', 'Ga - Gasto Amort.Iz. Marc', 'Ga - Gasto Amort.Iz. Marcas, Patentes, Derecho De Llave', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.23.', '5', 'Ga - Deterioro', 'Ga - Deterioro', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.23.01', '5', 'Ga - Deterioro Propiedade', 'Ga - Deterioro Propiedades, Planta Y Equipo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.23.02', '5', 'Ga - Deterioro Inventario', 'Ga - Deterioro Inventarios', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.23.03', '5', 'Ga - Deterioro Instrumento', 'Ga - Deterioro Instrumentos Financieros', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.23.04', '5', 'Ga - Deterioro Intangible', 'Ga - Deterioro Intangibles', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.23.05', '5', 'Ga - Deterioro Cuentas Po', 'Ga - Deterioro Cuentas Por Cobrar', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.23.06', '5', 'Ga - Deterioro Otros Acti', 'Ga - Deterioro Otros Activos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.', '5', 'Ga - Otros Gastos', 'Ga - Otros Gastos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.01', '5', 'Ga - Suministros De Aseo', 'Ga - Suministros De Aseo Y Limpieza', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.02', '5', 'Ga - Suministros Y Materia', 'Ga - Suministros Y Materiales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.05', '5', 'Ga - Capacitacion Y Semin', 'Ga - Capacitacion Y Seminarios', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.07', '5', 'Ga - Seguridad Y Monitore', 'Ga - Seguridad Y Monitoreo', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.09', '5', 'Ga - Suscripciones', 'Ga - Suscripciones', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.11', '5', 'Ga - Atencion Empleados', 'Ga - Atencion Empleados', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.13', '5', 'Ga - Donaciones Y Contrib', 'Ga - Donaciones Y Contribuciones Comuinidad', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.14', '5', 'Ga - Uniformes', 'Ga - Uniformes', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.15', '5', 'Ga- Autoconsumo Suministr', 'Ga- Autoconsumo Suministros', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.16', '5', 'Ga - Autoconsumo Alimento', 'Ga - Autoconsumo Alimentos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.17', '5', 'Ga- Autocunsomo Otros', 'Ga- Autocunsomo Otros', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.18', '5', 'Otros Gastos Servicios', 'Otros Gastos Servicios', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.19', '5', 'Otros Gastos Bienes', 'Otros Gastos Bienes', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.3.01.27.20', '5', 'Ga - Servicio Auditoria S', 'Ga - Servicio Auditoria Sociedades', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.', '5', 'Gastos Financieros', 'Gastos Financieros', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.', '5', 'Gastos Financieros', 'Gastos Financieros', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.01.', '5', 'Gastos Financieros', 'Gastos Financieros', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.01.01', '5', 'Gf - Intereses Bancarios', 'Gf - Intereses Bancarios', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.01.02', '5', 'Gf - Gastos Bancarios', 'Gf - Gastos Bancarios', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.01.03', '5', 'Gf - Gastos Financiamient', 'Gf - Gastos Financiamiento De Activos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.01.04', '5', 'Gf - Diferencia En Cambio', 'Gf - Diferencia En Cambio', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.01.05', '5', 'Gf - Otros Costos Financi', 'Gf - Otros Costos Financieros', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.01.06', '5', 'Gf- Seguro Pagado En Pré', 'Gf- Seguro Pagado En Préstamos', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.02.', '5', 'Otros Gastos', 'Otros Gastos', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.02.01', '5', 'Gf - Perdida En Inversio', 'Gf - Perdida En Inversiones En Asociadas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.4.01.02.02', '5', 'Gf - Otros', 'Gf - Otros', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.5.', '5', 'Gastos No Deducibles', 'Gastos No Deducibles', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.5.01.', '5', 'Gastos No Deducibles', 'Gastos No Deducibles', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.5.01.01.', '5', 'Gastos No Deducibles', 'Gastos No Deducibles', 'MAY', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.5.01.01.01', '5', 'Gnd - Gasto No Deducible G', 'Gnd - Gasto No Deducible Generales', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.5.01.01.02', '5', 'Devolucion Juguetes 2017', 'Devolucion Juguetes 2017', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.5.01.01.03', '5', 'Gnd- Ingreso Y Egreso Fac', 'Gnd- Ingreso Y Egreso Facturas Mal Emitidas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT'),
('5.5.01.01.04', '5', 'Gastos No Deducible Ajust', 'Gastos No Deducible Ajuste Cuentas', 'DET', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, USER(), 'ACT');


-- 3.4 ENTIDADES COMERCIALES (31 Proveedores)
INSERT INTO PROVEEDORES (id_Proveedor, prv_Nombre, prv_RUC_CED, prv_Telefono, prv_Mail, id_Ciudad, prv_Celular, prv_Direccion, ESTADO_PRV) VALUES 
('PRV-001', 'CORPORACION FAVORITA C.A.', '1790016919001', '022996500', 'compras@favorita.ec', 'UIO', '0991234567', 'Av. General Enríquez, Vía Cotogchoa', 'ACT'),
('PRV-002', 'PRONACA S.A.', '1790008881001', '022996501', 'ventas@pronaca.com', 'UIO', '0991234568', 'Los Naranjos N44-15', 'ACT'),
('PRV-003', 'UNILEVER ANDINA', '0990004196001', '042598700', 'b2b@unilever.com.ec', 'GYE', '0991234569', 'Km 25 Vía a Daule', 'ACT'),
('PRV-004', 'LA FABRIL S.A.', '1390006295001', '052655000', 'pedidos@lafabril.com.ec', 'MNT', '0991234570', 'Km 5.5 Vía Manta - Montecristi', 'ACT'),
('PRV-005', 'NESTLE ECUADOR S.A.', '1790012587001', '022996504', 'servicios@nestle.ec', 'UIO', '0991234571', 'Av. Simón Bolívar', 'ACT'),
('PRV-006', 'ALPINA PRODUCTOS ALIM.', '1790486672001', '022996505', 'ventas@alpina.com', 'UIO', '0991234572', 'Panamericana Norte Km 14', 'ACT'),
('PRV-007', 'CERVECERIA NACIONAL', '0990000352001', '042598706', 'preventa@cn.com.ec', 'GYE', '0991234573', 'Vía a Daule Km 16.5', 'ACT'),
('PRV-008', 'CONFITECA C.A.', '1790003669001', '022996507', 'dulces@confiteca.ec', 'UIO', '0991234574', 'Panamericana Sur Km 10', 'ACT'),
('PRV-009', 'INDUSTRIAL DANEC', '1790003014001', '022996508', 'aceites@danec.com', 'UIO', '0991234575', 'Av. León Febres Cordero', 'ACT'),
('PRV-010', 'SUMESA S.A.', '0990002169001', '042598709', 'ventas@sumesa.com.ec', 'GYE', '0991234576', 'Km 11.5 Vía a Daule', 'ACT'),
('PRV-011', 'GRUPO DIFARE S.A.', '0990015505001', '042333444', 'compras@difare.com', 'GYE', '0998000011', 'CIUDAD COLON EDIF 2', 'ACT'),
('PRV-012', 'FARMAENLACE CIA. LTDA.', '1791353381001', '022888999', 'prov@farmaenlace.com', 'UIO', '0998000012', 'CAPITAN RAMOS Y GALO PLAZA', 'ACT'),
('PRV-013', 'LABORATORIOS LIFE', '1790006781001', '022444555', 'ventas@life.com.ec', 'UIO', '0998000013', 'AV. DE LA PRENSA Y EDROY', 'ACT'),
('PRV-014', 'INDURAMA', '0190005556001', '072800800', 'ventas@indurama.com', 'CUE', '0998000014', 'PARQUE INDUSTRIAL CUENCA', 'ACT'),
('PRV-015', 'MABE ECUADOR', '0990023001001', '042111222', 'distribucion@mabe.com.ec', 'GYE', '0998000015', 'KM 14 VIA DAULE', 'ACT'),
('PRV-016', 'COMPUTRON S.A.', '0990009999001', '042200200', 'b2b@computron.com.ec', 'GYE', '0998000016', 'CC PLAZA QUIL LOCAL 5', 'ACT'),
('PRV-017', 'INTCOMEX ECUADOR', '1792008888001', '022999000', 'ventas@intcomex.com.ec', 'UIO', '0998000017', 'ELOY ALFARO Y DE LOS PINOS', 'ACT'),
('PRV-018', 'HOLCIM ECUADOR S.A.', '0990006789001', '042999000', 'pedidos@holcim.com', 'GYE', '0998000018', 'AV BARCELONA', 'ACT'),
('PRV-019', 'NOVACERO S.A.', '1790005555001', '022555666', 'ventas@novacero.com', 'UIO', '0998000019', 'PANAMERICANA SUR KM 16', 'ACT'),
('PRV-020', 'GRAIMAN CIA. LTDA.', '0190034444001', '072866666', 'proyectos@graiman.com', 'CUE', '0998000020', 'PANAMERICANA NORTE KM 12', 'ACT'),
('PRV-021', 'KYWI S.A.', '1790004561001', '022998877', 'proveeduria@kywi.com.ec', 'UIO', '0998000021', 'AV. 10 DE AGOSTO Y NACIONES', 'ACT'),
('PRV-022', 'FV AREA ANDINA', '1791223344001', '022333111', 'ventas@fvandina.com', 'UIO', '0998000022', 'VIA AMAGUANA KM 20', 'ACT'),
('PRV-023', 'INDUSTRIA LECHERA TONI', '0990001122001', '042004005', 'ventas@toni.com.ec', 'GYE', '0998000023', 'KM 14 VIA A DAULE', 'ACT'),
('PRV-024', 'PASTEURIZADORA QUITO', '1790018881001', '022666777', 'pedidos@vita.com.ec', 'UIO', '0998000024', 'AV MARISCAL SUCRE S/N', 'ACT'),
('PRV-025', 'INDUSTRIA LOJANA ILE', '1190003333001', '072570570', 'ventas@ile.com.ec', 'LOJ', '0998000025', 'PARQUE INDUSTRIAL LOJA', 'ACT'),
('PRV-026', 'NIRSA (REAL)', '0990005511001', '042505050', 'pedidos@nirsa.com', 'GYE', '0998000026', 'POSORJA BARRIO QUITO', 'ACT'),
('PRV-027', 'SUPERIOR (FIDEOS)', '1790022233001', '022444888', 'ventas@superior.com.ec', 'UIO', '0998000027', 'AV GALO PLAZA LASSO', 'ACT'),
('PRV-028', 'CONTINENTAL TIRE', '0190002222001', '072800100', 'ventas@conti.com.ec', 'CUE', '0998000028', 'PARQUE INDUSTRIAL CUENCA', 'ACT'),
('PRV-029', 'PLASTICAUCHO INDUSTRIAL', '1890004567001', '032888111', 'venus@plasticaucho.com.ec', 'AMB', '0998000029', 'CATIGLATA AMBATO', 'ACT'),
('PRV-030', 'CHAIDE Y CHAIDE', '1790033344001', '022400500', 'pedidos@chaide.com', 'UIO', '0998000030', 'AV ELOY ALFARO', 'ACT'),
('PRV-031', 'ARCA CONTINENTAL', '1790013796001', '022262000', 'pedidos@arcacontal.com', 'UIO', '0998000031', 'AV. ISAAC ALBENIZ', 'ACT');

INSERT INTO CLIENTES (id_Cliente, cli_Nombre, cli_RUC_CED, cli_Telefono, cli_Mail, id_Ciudad, cli_Celular, cli_Direccion, ESTADO_CLI) VALUES 
('CLI-001', 'JUAN PEREZ', '1710000001', '022333001', 'juan@gmail.com', 'UIO', '098888801', 'El Inca', 'ACT'),
('CLI-002', 'MARIA LOPEZ', '0910000002', '042333002', 'maria@hotmail.com', 'GYE', '098888802', 'Urdesa', 'ACT'),
('CLI-003', 'CARLOS VITERI', '0101000003', '072333003', 'carlos@yahoo.com', 'CUE', '098888803', 'Totoracocha', 'ACT'),
('CLI-004', 'TIENDA DON PEPE', '1710000004001', '022333004', 'donpepe@tienda.com', 'UIO', '098888804', 'Comite del Pueblo', 'ACT'),
('CLI-005', 'FARMACIA CRUZ', '1790000005001', '022333005', 'compras@cruz.com', 'UIO', '098888805', 'Villa Flora', 'ACT'),
('CLI-006', 'ANA GOMEZ', '1710000006', '022333006', 'ana@gmail.com', 'AMB', '098888806', 'Ficoa', 'ACT'),
('CLI-007', 'LUIS TORRES', '1301000007', '052333007', 'luis@outlook.com', 'MNT', '098888807', 'El Murcielago', 'ACT'),
('CLI-008', 'RESTAURANTE EL SABOR', '1790000008001', '022333008', 'chef@sabor.com', 'UIO', '098888808', 'La Mariscal', 'ACT'),
('CLI-009', 'PEDRO ALVARADO', '1101000009', '072333009', 'pedro@loja.net', 'LOJ', '098888809', 'San Sebastian', 'ACT'),
('CLI-10', 'CONSTRUCTORA XYZ', '1790000010001', '022333010', 'compras@xyz.com', 'UIO', '098888810', 'Cumbaya', 'ACT');

-- 3.5 PRODUCTOS (Corregido 'PAQ' en Papel Higienico)
INSERT INTO PRODUCTOS (id_Producto, pro_Descripcion, pro_UM_Compra, pro_UM_Venta, pro_Valor_Compra, pro_Precio_Venta, pro_Saldo_Inicial, pro_Qty_Ingresos, pro_Qty_Egresos, pro_Qty_Ajustes, pro_Saldo_Final, ESTADO_PROD) VALUES 
('PRO-001', 'ARROZ SUPER 5KG', 'SAC', 'UNI', 40.00, 5.50, 100, 50, 0, 0, 150, 'ACT'), 
('PRO-002', 'ATUN REAL LATA', 'CJA', 'UNI', 48.00, 1.25, 200, 100, 0, 0, 300, 'ACT'), 
('PRO-003', 'ACEITE GIRASOL 1LT', 'CJA', 'UNI', 24.00, 2.50, 50, 20, 0, 0, 70, 'ACT'), 
('PRO-004', 'LECHE PARMALAT', 'CJA', 'UNI', 12.00, 1.10, 100, 100, 0, 0, 200, 'ACT'),
('PRO-005', 'AZUCAR SAN CARLOS 2KG', 'SAC', 'UNI', 35.00, 2.20, 80, 40, 0, 0, 120, 'ACT'),
('PRO-006', 'FIDEOS SUMESA', 'PAQ', 'UNI', 10.00, 0.60, 150, 50, 0, 0, 200, 'ACT'),
('PRO-007', 'COLA COCA COLA 3LT', 'JAV', 'UNI', 18.00, 3.00, 60, 60, 0, 0, 120, 'ACT'), 
('PRO-008', 'JABON PROTEX', 'CJA', 'UNI', 15.00, 1.00, 100, 20, 0, 0, 120, 'ACT'),
('PRO-009', 'DETERGENTE DEJA', 'SAC', 'UNI', 25.00, 3.50, 40, 20, 0, 0, 60, 'ACT'),
('PRO-010', 'PAPEL HIGIENICO FAM', 'PAQ', 'UNI', 12.00, 4.00, 50, 50, 0, 0, 100, 'ACT');

-- 3.6 TRANSACCIONES (CABECERAS Y DETALLES)

INSERT INTO COMPRAS (id_Compra, id_Proveedor, oc_Fecha_Hora, oc_Subtotal, oc_IVA, ESTADO_OC) VALUES 
('OC-001', 'PRV-001', '2025-01-02 09:00:00', 385.00, 15, 'PRO'), 
('OC-002', 'PRV-002', '2025-01-03 10:00:00', 240.00, 15, 'PRO'),
('OC-003', 'PRV-003', '2025-01-04 11:30:00', 480.00, 15, 'PRO'),
('OC-004', 'PRV-004', '2025-01-05 09:15:00', 108.00, 15, 'PRO'),
('OC-005', 'PRV-010', '2025-01-06 14:00:00', 120.00, 15, 'PRO'),
('OC-006', 'PRV-009', '2025-01-07 16:20:00', 450.00, 15, 'PRO'),
('OC-007', 'PRV-003', '2025-01-08 10:00:00', 240.00, 15, 'PRO'),
('OC-008', 'PRV-008', '2025-01-09 11:00:00', 420.00, 15, 'PRO'),
('OC-009', 'PRV-007', '2025-01-10 12:00:00', 180.00, 15, 'PRO'),
('OC-010', 'PRV-005', '2025-01-11 13:00:00', 150.00, 15, 'PEN'); 

INSERT INTO PROxOC (id_Compra, id_Producto, pxo_Cantidad, pxo_Valor, ESTADO_PxOC) VALUES 
('OC-001', 'PRO-001', 10, 38.50, 'ACT'), ('OC-002', 'PRO-002', 10, 24.00, 'ACT'),
('OC-003', 'PRO-003', 10, 48.00, 'ACT'), ('OC-004', 'PRO-004', 10, 10.80, 'ACT'),
('OC-005', 'PRO-005', 10, 12.00, 'ACT'), ('OC-006', 'PRO-006', 10, 45.00, 'ACT'),
('OC-007', 'PRO-007', 10, 24.00, 'ACT'), ('OC-008', 'PRO-008', 10, 42.00, 'ACT'),
('OC-009', 'PRO-009', 10, 18.00, 'ACT'), ('OC-010', 'PRO-010', 10, 15.00, 'ACT');

INSERT INTO RECEPCIONES (id_Recibo, USER_ID, rec_Descripcion, rec_FechaHora, rec_Num_Produc, ESTADO_REC) VALUES 
('REC-001', 'EMP-COM', 'INGRESO OC-001', '2025-01-02 11:00:00', 1, 'ACT'),
('REC-002', 'EMP-COM', 'INGRESO OC-002', '2025-01-03 12:00:00', 1, 'ACT'),
('REC-003', 'EMP-COM', 'INGRESO OC-003', '2025-01-04 14:00:00', 1, 'ACT'),
('REC-004', 'EMP-COM', 'INGRESO OC-004', '2025-01-05 10:00:00', 1, 'ACT'),
('REC-005', 'EMP-COM', 'INGRESO OC-005', '2025-01-06 15:00:00', 1, 'ACT'),
('REC-006', 'EMP-COM', 'INGRESO OC-006', '2025-01-07 17:00:00', 1, 'ACT'),
('REC-007', 'EMP-COM', 'INGRESO OC-007', '2025-01-08 11:00:00', 1, 'ACT'),
('REC-008', 'EMP-COM', 'INGRESO OC-008', '2025-01-09 13:00:00', 1, 'ACT'),
('REC-009', 'EMP-COM', 'INGRESO OC-009', '2025-01-10 14:00:00', 1, 'ACT'),
('REC-010', 'EMP-COM', 'INGRESO OC-010', '2025-01-11 15:00:00', 1, 'ACT');

INSERT INTO PROxREC (id_Recibo, id_Producto, pxr_Cantidad, pxr_Qty_Recibida, ESTADO_PxR) VALUES 
('REC-001', 'PRO-001', 10, 10, 'ACT'), ('REC-002', 'PRO-002', 10, 10, 'ACT'),
('REC-003', 'PRO-003', 10, 10, 'ACT'), ('REC-004', 'PRO-004', 10, 10, 'ACT'),
('REC-005', 'PRO-005', 10, 10, 'ACT'), ('REC-006', 'PRO-006', 10, 10, 'ACT'),
('REC-007', 'PRO-007', 10, 10, 'ACT'), ('REC-008', 'PRO-008', 10, 10, 'ACT'),
('REC-009', 'PRO-009', 10, 10, 'ACT'), ('REC-010', 'PRO-010', 10, 10, 'ACT');

INSERT INTO FACTURAS (id_Factura, id_Cliente, fac_Fecha_Hora, fac_Subtotal, fac_IVA, ESTADO_FAC) VALUES 
('FAC-001', 'CLI-001', '2025-01-12 09:30:00', 9.50, 15, 'COB'),
('FAC-002', 'CLI-002', '2025-01-12 10:45:00', 12.50, 15, 'COB'),
('FAC-003', 'CLI-003', '2025-01-12 11:20:00', 40.50, 15, 'COB'),
('FAC-004', 'CLI-004', '2025-01-13 09:00:00', 5.50, 15, 'COB'),
('FAC-005', 'CLI-005', '2025-01-13 14:00:00', 19.50, 15, 'COB'),
('FAC-006', 'CLI-006', '2025-01-14 16:00:00', 15.20, 15, 'COB'),
('FAC-007', 'CLI-007', '2025-01-15 10:00:00', 10.00, 15, 'COB'),
('FAC-008', 'CLI-008', '2025-01-16 11:30:00', 4.30, 15, 'COB'),
('FAC-009', 'CLI-009', '2025-01-17 12:45:00', 27.50, 15, 'PEN'),
('FAC-010', 'CLI-10', '2025-01-18 09:15:00', 45.00, 15, 'COB');

INSERT INTO PROxFAC (id_Factura, id_Producto, pxf_Cantidad, pxf_Valor, ESTADO_PxF) VALUES 
('FAC-001', 'PRO-001', 2, 4.75, 'ACT'), ('FAC-002', 'PRO-002', 5, 2.50, 'ACT'),
('FAC-003', 'PRO-003', 30, 1.35, 'ACT'), ('FAC-004', 'PRO-004', 5, 1.10, 'ACT'),
('FAC-005', 'PRO-005', 30, 0.65, 'ACT'), ('FAC-006', 'PRO-006', 4, 3.80, 'ACT'),
('FAC-007', 'PRO-007', 10, 1.00, 'ACT'), ('FAC-008', 'PRO-008', 2, 2.15, 'ACT'),
('FAC-009', 'PRO-009', 10, 2.75, 'ACT'), ('FAC-010', 'PRO-010', 10, 4.50, 'ACT');

INSERT INTO ENTREGAS (id_Entrega, USER_ID, ent_Descripcion, ent_FechaHora, ent_Num_Produc, ESTADO_ENT) VALUES 
('ENT-001', 'EMP-COM', 'DESPACHO FAC-001', '2025-01-12 09:35:00', 1, 'ACT'),
('ENT-002', 'EMP-COM', 'DESPACHO FAC-002', '2025-01-12 10:50:00', 1, 'ACT'),
('ENT-003', 'EMP-COM', 'DESPACHO FAC-003', '2025-01-12 11:30:00', 1, 'ACT'),
('ENT-004', 'EMP-COM', 'DESPACHO FAC-004', '2025-01-13 09:10:00', 1, 'ACT'),
('ENT-005', 'EMP-COM', 'DESPACHO FAC-005', '2025-01-13 14:10:00', 1, 'ACT'),
('ENT-006', 'EMP-COM', 'DESPACHO FAC-006', '2025-01-14 16:10:00', 1, 'ACT'),
('ENT-007', 'EMP-COM', 'DESPACHO FAC-007', '2025-01-15 10:10:00', 1, 'ACT'),
('ENT-008', 'EMP-COM', 'DESPACHO FAC-008', '2025-01-16 11:40:00', 1, 'ACT'),
('ENT-009', 'EMP-COM', 'DESPACHO FAC-009', '2025-01-17 13:00:00', 1, 'ACT'),
('ENT-010', 'EMP-COM', 'DESPACHO FAC-010', '2025-01-18 09:30:00', 1, 'ACT');

INSERT INTO PROxENT (id_Entrega, id_Producto, pxe_Cantidad, pxe_Qty_Entregada, ESTADO_PxE) VALUES 
('ENT-001', 'PRO-001', 2, 2, 'ACT'), ('ENT-002', 'PRO-002', 5, 5, 'ACT'),
('ENT-003', 'PRO-003', 30, 30, 'ACT'), ('ENT-004', 'PRO-004', 5, 5, 'ACT'),
('ENT-005', 'PRO-005', 30, 30, 'ACT'), ('ENT-006', 'PRO-006', 4, 4, 'ACT'),
('ENT-007', 'PRO-007', 10, 10, 'ACT'), ('ENT-008', 'PRO-008', 2, 2, 'ACT'),
('ENT-009', 'PRO-009', 10, 10, 'ACT'), ('ENT-010', 'PRO-010', 10, 10, 'ACT');

INSERT INTO AJUSTES (id_Ajuste, USER_ID, aju_Descripcion, aju_FechaHora, aju_Num_Produc, ESTADO_AJU) VALUES 
('AJU-001', 'EMP-COM', 'MERMA ARROZ', '2025-01-20 10:00:00', 1, 'ACT');

INSERT INTO PROxAJU (id_Ajuste, id_Producto, pxa_Cantidad, pxa_Qty_Ajustada, ESTADO_PxA) VALUES 
('AJU-001', 'PRO-001', -1, -1, 'ACT');

INSERT INTO ASIENTOS (ID_ASIENTOCONTABLE, ASI_FECHAHORA, ASI_DESCRIPCION, ASI_ESTADOASIENTO, ASI_TOTAL_DEBE, ASI_TOTAL_HABER, ASI_USERID) VALUES
-- Compras (Basado en CMP-000001, 000002, 000003)
('C-A-000001', '2024-01-15 00:00:00', 'Registro de compra CMP-000001 al proveedor PROV000025.', 'BOR', 1150.00, 1150.00, 'EMP-777'),
('C-A-000002', '2024-02-10 00:00:00', 'Registro de compra CMP-000002 al proveedor PROV000026.', 'BOR', 1725.00, 1725.00, 'EMP-777'),
('C-A-000003', '2024-03-05 00:00:00', 'Registro de compra CMP-000003 al proveedor PROV000027.', 'BOR', 2530.00, 2530.00, 'EMP-777'),

-- Ventas (Factura y Descuentos)
('V-A-000004', '2024-01-20 00:00:00', 'Registro de Venta COMP-00001. Total a cobrar: 927.50', 'BOR', 977.50, 977.50, 'EMP-777'), -- (850-50)+127.50 = 927.50 + 50.00 (descuento)
('V-A-000005', '2024-02-15 00:00:00', 'Registro de Venta COMP-00002. Total a cobrar: 1380.00', 'BOR', 1380.00, 1380.00, 'EMP-777'),

-- Costo de Venta (Asociado a las ventas anteriores)
('X-A-000006', '2024-01-20 00:00:00', 'Registro de Costo de Venta por COMP-00001.', 'BOR', 661.50, 661.50, 'EMP-777'),
('X-A-000007', '2024-02-15 00:00:00', 'Registro de Costo de Venta por COMP-00002.', 'BOR', 946.50, 946.50, 'EMP-777'),

-- Nómina (Suma de ROLPAS pagados)
('R-A-000008', '2024-01-31 00:00:00', 'Registro Gasto Nómina Enero 2024.', 'BOR', 1750.00, 1750.00, 'EMP-1110'),
('R-A-000009', '2024-02-29 00:00:00', 'Registro Gasto Nómina Febrero 2024.', 'BOR', 1750.00, 1750.00, 'EMP-1110'),

-- Ajuste de Inventario (Ajuste A0001)
('A-A-000010', '2024-03-15 14:30:00', 'Ajuste A0001 por diferencia de inventario físico.', 'BOR', 39.20, 39.20, 'EMP-555');



/*==============================================================*/
-- Asiento AN-0001
INSERT INTO CUENTASXASIENTO (ID_CODIGOCUENTA, ID_ASIENTOCONTABLE, CXA_MONTODEBE, CXA_MONTOHABER, CXA_DESCRIPCION, CXA_ESTADOCXA) VALUES
-- C-A-000001: Compra CMP-000001 (Total: 1150.00)
('1.1.03.01.01', 'C-A-000001', 1000.00, 0.00, 'Inventario por compra CMP-000001 (Subtotal)', 'VAL'),
('1.1.05.01.01', 'C-A-000001', 150.00, 0.00, 'IVA en Compras por CMP-000001', 'VAL'),
('2.1.03.01.01', 'C-A-000001', 0.00, 1150.00, 'Proveedores Locales (CMP-000001)', 'VAL'),

-- C-A-000002: Compra CMP-000002 (Total: 1725.00)
('1.1.03.01.01', 'C-A-000002', 1500.00, 0.00, 'Inventario por compra CMP-000002 (Subtotal)', 'VAL'),
('1.1.05.01.01', 'C-A-000002', 225.00, 0.00, 'IVA en Compras por CMP-000002', 'VAL'),
('2.1.03.01.01', 'C-A-000002', 0.00, 1725.00, 'Proveedores Locales (CMP-000002)', 'VAL'),

-- C-A-000003: Compra CMP-000003 (Total: 2530.00)
('1.1.03.01.01', 'C-A-000003', 2200.00, 0.00, 'Inventario por compra CMP-000003 (Subtotal)', 'VAL'),
('1.1.05.01.01', 'C-A-000003', 330.00, 0.00, 'IVA en Compras por CMP-000003', 'VAL'),
('2.1.03.01.01', 'C-A-000003', 0.00, 2530.00, 'Proveedores Locales (CMP-000003)', 'VAL'),

-- V-A-000004: Venta COMP-00001 (Total Asiento: 977.50)
('1.1.02.05.01', 'V-A-000004', 927.50, 0.00, 'Clientes Locales (977.50 Total - 50.00 Descuento)', 'VAL'),
('4.1.01.02', 'V-A-000004', 50.00, 0.00, 'Descuento sobre Ventas (COMP-00001)', 'VAL'),
('4.1.01.01', 'V-A-000004', 0.00, 850.00, 'Ventas Bienes con IVA (Subtotal 15%)', 'VAL'),
('2.1.07.01.02.01', 'V-A-000004', 0.00, 127.50, 'IVA en Ventas (15% de 850.00)', 'VAL'),

-- V-A-000005: Venta COMP-00002 (Total Asiento: 1380.00)
('1.1.02.05.01', 'V-A-000005', 1380.00, 0.00, 'Clientes Locales (1200.00 + 180.00 IVA)', 'VAL'),
('4.1.01.01', 'V-A-000005', 0.00, 1200.00, 'Ventas Bienes con IVA (Subtotal 15%)', 'VAL'),
('2.1.07.01.02.01', 'V-A-000005', 0.00, 180.00, 'IVA en Ventas (15% de 1200.00)', 'VAL'),

-- X-A-000006: Costo de Venta COMP-00001 (Total Asiento: 661.50)
('5.1.01.01.01', 'X-A-000006', 661.50, 0.00, 'Costo de Ventas Mercadería (COMP-00001)', 'VAL'),
('1.1.03.01.01', 'X-A-000006', 0.00, 661.50, 'Inventario de Productos Terminados (Salida)', 'VAL'),

-- X-A-000007: Costo de Venta COMP-00002 (Total Asiento: 946.50)
('5.1.01.01.01', 'X-A-000007', 946.50, 0.00, 'Costo de Ventas Mercadería (COMP-00002)', 'VAL'),
('1.1.03.01.01', 'X-A-000007', 0.00, 946.50, 'Inventario de Productos Terminados (Salida)', 'VAL'),

-- R-A-000008: Nómina Enero (Total Asiento: 5250.00)
('5.3.01.01.01', 'R-A-000008', 5250.00, 0.00, 'Gasto de Sueldos Unificados (3 * 1750.00)', 'VAL'),
('2.1.07.01.01.17', 'R-A-000008', 0.00, 600.00, 'Retenciones/Aportes IESS por Pagar (3 * 200.00)', 'VAL'),
('1.1.01.02.01', 'R-A-000008', 0.00, 4650.00, 'Banco (Pa Neto de Nómina)', 'Val'),

-- R-A-000009: Nómina Febrero (Total Asiento: 3500.00)
('5.3.01.01.01', 'R-A-000009', 3500.00, 0.00, 'Gasto de Sueldos Unificados (2 * 1750.00)', 'VAL'),
('2.1.07.01.01.17', 'R-A-000009', 0.00, 400.00, 'Retenciones/Aportes IESS por Pagar (2 * 200.00)', 'VAL'),
('1.1.01.02.01', 'R-A-000009', 0.00, 3100.00, 'Banco (Pa Neto de Nómina)', 'VAL'),

-- A-A-000010: Ajuste A0001 (Total Asiento: 39.20)
('5.2.01.23.02', 'A-A-000010', 39.20, 0.00, 'Gasto por Deterioro/Ajuste de Inventarios (A0001)', 'VAL'),
('1.1.03.01.01', 'A-A-000010', 0.00, 39.20, 'Inventario de Productos Terminados (Salida por Ajuste)', 'VAL');

INSERT INTO Cargas (id_Carga, car_Cedula, car_Apellido1, car_Apellido2, car_Nombre1, car_Nombre2, car_Sexo, car_FechaNacimiento, ESTADO_CAR, id_Empleado) VALUES
('C-0001', '0104567001', 'Perez', 'Lopez', 'Ana', '','F', '1982-07-23', 'ACT', 3),
('C-0002', '0104567002', 'Garcia', 'Martinez', 'Luis', '','M', '1990-11-14', 'ACT', 3),
('C-0003', '0104567003', 'Lopez', 'Rodriguez', 'Carlos', '','M', '1987-01-05', 'ACT', 7),
('C-0004', '0104567004', 'Martinez', 'Garcia', 'Maria', '','F', '1975-04-29', 'ACT', 12),
('C-0005', '0104567005', 'Rodriguez', 'Johnson', 'James', '','M', '1993-08-16', 'ACT', 12),
('C-0006', '0104567006', 'Johnson', 'Brown', 'Elena', '','F', '1989-10-12', 'ACT', 20),
('C-0007', '0104567007', 'Smith', 'Davis', 'Pedro', '','M', '1995-12-31', 'ACT', 27),
('C-0008', '0104567008', 'Brown', 'Wilson', 'Sarah', '','F', '1983-03-22', 'ACT', 30),
('C-0009', '1708558430', 'Cóndor', 'Andrade', 'Patricia', 'Paola','F', '1994-05-05', 'ACT', 99),
('C-0010', '0104567010', 'Wilson', 'Martinez', 'Juan', '','M', '1988-06-05', 'ACT', 40),
('C-0011', '0104567011', 'Perez', 'Rodriguez', 'Ana', '','F', '1991-11-21', 'ACT', 44),
('C-0012', '0104567012', 'Garcia', 'Smith', 'Luis', '','M', '1974-01-01', 'ACT', 53),
('C-0013', '0104567013', 'Lopez', 'Brown', 'Carlos', '','M', '1985-12-02', 'ACT', 65),
('C-0014', '0104567014', 'Martinez', 'Davis', 'Maria', '','F', '1989-05-11', 'ACT', 71),
('C-0015', '0104567015', 'Rodriguez', 'Wilson', 'James', '','M', '1993-04-14', 'ACT', 82),
('C-0016', '0104567016', 'Johnson', 'Perez', 'Elena', '','F', '1977-07-03', 'ACT', 91),
('C-0017', '0104567017', 'Smith', 'Johnson', 'Pedro', '','M', '1980-10-09', 'ACT', 105),
('C-0018', '0104567018', 'Brown', 'Smith', 'Sarah', '','F', '1973-02-26', 'ACT', 117),
('C-0019', '1708558432', 'Cóndor', 'Andrade', 'Lino', 'javier','M', '1995-09-09', 'ACT', 99),
('C-0020', '0104567020', 'Wilson', 'Lopez', 'Juan', '','M', '1990-09-25', 'ACT', 144),
('C-0021', '1704567021', 'Lopez', 'Garcia', 'Ana', '','F', '1981-10-21', 'ACT', 13),
('C-0022', '1704567022', 'Martinez', 'Rodriguez', 'Luis', '','M', '1992-05-02', 'ACT', 15),
('C-0023', '1704567023', 'Rodriguez', 'Johnson', 'Carlos', '','M', '1979-08-13', 'ACT', 17),
('C-0024', '1704567024', 'Johnson', 'Martinez', 'Gabriela', '','F', '1990-12-11', 'ACT', 18),
('C-0025', '1704567025', 'Smith', 'Perez', 'James', '','M', '1985-07-07', 'ACT', 20),
('C-0026', '1704567026', 'Brown', 'Wilson', 'Sarah', '','F', '1991-04-25', 'ACT', 21),
('C-0027', '1704567027', 'Davis', 'Lopez', 'Elena', '','F', '1986-09-10', 'ACT', 23),
('C-0028', '1704567028', 'Wilson', 'Brown', 'Juan', '','M', '1977-11-19', 'ACT', 24),
('C-0029', '1704567029', 'Perez', 'Smith', 'Ana', '','F', '1988-01-30', 'ACT', 26),
('C-0030', '1704567030', 'Garcia', 'Davis', 'Luis', '','M', '1994-03-14', 'ACT', 27),
('C-0031', '1704567031', 'Lopez', 'Wilson', 'Carlos', '','M', '1982-12-23', 'ACT', 31),
('C-0032', '1704567032', 'Martinez', 'Garcia', 'Maria', '','F', '1974-06-04', 'ACT', 33),
('C-0033', '1704567033', 'Rodriguez', 'Smith', 'James', '','M', '1987-09-22', 'ACT', 35),
('C-0034', '1704567034', 'Johnson', 'Perez', 'Elena', '','F', '1983-11-18', 'ACT', 37),
('C-0035', '1704567035', 'Smith', 'Brown', 'Pedro', '','M', '1991-07-15', 'ACT', 40),
('C-0036', '1704567036', 'Brown', 'Martinez', 'Gabriela', '','F', '1984-05-06', 'ACT', 42),
('C-0037', '1704567037', 'Davis', 'Wilson', 'Carlos', '','M', '1978-03-29', 'ACT', 44),
('C-0038', '1704567038', 'Wilson', 'Johnson', 'Sarah', '','F', '1979-08-09', 'ACT', 46),
('C-0039', '1704567039', 'Perez', 'Rodriguez', 'James', '','M', '1980-02-19', 'ACT', 48),
('C-0040', '1704567040', 'Garcia', 'Smith', 'Luis', '','M', '1993-12-03', 'ACT', 50);

-- (20) BONIFICACIONES
INSERT INTO Bonificaciones (id_Bonificacion, bon_Descripcion, bon_Valor, ESTADO_BON) VALUES
('B-0001', 'Bonificación Anual', 1500, 'ACT'),
('B-0002', 'Bonificación de Desempeño', 1000, 'ACT'),
('B-0003', 'Bono de Puntualidad', 300, 'ACT'),
('B-0004', 'Bonificación por Ventas', 1200, 'ACT'),
('B-0005', 'Bono por Productividad', 800, 'ACT'),
('B-0006', 'Bonificación de Navidad', 500, 'ACT'),
('B-0007', 'Bonificación de Fiestas', 450, 'ACT'),
('B-0008', 'Bono de Cumpleaños', 200, 'ACT'),
('B-0009', 'Bono por Antigüedad', 750, 'ACT'),
('B-0010', 'Bono Escolar', 250, 'ACT'),
('B-0011', 'Bonificación por Horas Extras', 600, 'ACT'),
('B-0012', 'Bonificación por Turno Nocturno', 400, 'ACT'),
('B-0013', 'Bono de Recomendación', 300, 'ACT'),
('B-0014', 'Bono por Liderazgo', 950, 'ACT'),
('B-0015', 'Bonificación de Seguridad', 500, 'ACT'),
('B-0016', 'Bono por Mejora Continua', 700, 'ACT'),
('B-0017', 'Bono de Capacitación', 350, 'ACT'),
('B-0018', 'Bonificación por Logro de Metas', 1000, 'ACT'),
('B-0019', 'Bono de Flexibilidad Laboral', 400, 'ACT'),
('B-0020', 'Bonificación por Asistencia Perfecta', 250, 'ACT');

-- (20) DESCUENTOS
INSERT INTO Descuentos (id_Descuento, des_Descripcion, des_Valor, ESTADO_DES) VALUES
('D-0001', 'Descuento de Seguro Médico', 200, 'ACT'),
('D-0002', 'Descuento de Aporte al IESS', 300, 'ACT'),
('D-0003', 'Descuento por Atrasos', 50, 'ACT'),
('D-0004', 'Descuento por Faltas', 100, 'ACT'),
('D-0005', 'Descuento de Seguro de Vida', 150, 'ACT'),
('D-0006', 'Descuento por Préstamo Personal', 400, 'ACT'),
('D-0007', 'Descuento de Seguro de Accidentes', 120, 'ACT'),
('D-0008', 'Descuento de Fondo de Pensiones', 350, 'ACT'),
('D-0009', 'Descuento por Uso de Herramientas', 70, 'ACT'),
('D-0010', 'Descuento por Capacitación', 80, 'ACT'),
('D-0011', 'Descuento de Uniforme', 90, 'ACT'),
('D-0012', 'Descuento de Beneficio Social', 250, 'ACT'),
('D-0013', 'Descuento de Comisión Administrativa', 60, 'ACT'),
('D-0014', 'Descuento por Dañado de Equipos', 150, 'ACT'),
('D-0015', 'Descuento por Permisos No Pagados', 100, 'ACT'),
('D-0016', 'Descuento de Fondo de Ahorro', 200, 'ACT'),
('D-0017', 'Descuento por Servicios Médicos', 300, 'ACT'),
('D-0018', 'Descuento de Préstamo de Vivienda', 500, 'ACT'),
('D-0019', 'Descuento por Planificación Familiar', 120, 'ACT'),
('D-0020', 'Descuento por Convenio Educativo', 150, 'ACT');

-- (24) PAGOS
INSERT INTO Pagos (id_Pago, pag_Descripcion, pag_Fecha_Inicio, pag_Fecha_Fin, Estado_pag) VALUES
('2023-01', 'Rol de pago - Enero', '2023-01-01', '2023-01-31', 'ACT'),
('2023-02', 'Rol de pago - Febrero', '2023-02-01', '2023-02-28', 'ACT'),
('2023-03', 'Rol de pago - Marzo', '2023-03-01', '2023-03-31', 'ACT'),
('2023-04', 'Rol de pago - Abril', '2023-04-01', '2023-04-30', 'ACT'),
('2023-05', 'Rol de pago - Mayo', '2023-05-01', '2023-05-31', 'ACT'),
('2023-06', 'Rol de pago - Junio', '2023-06-01', '2023-06-30', 'ACT'),
('2023-07', 'Rol de pago - Julio', '2023-07-01', '2023-07-31', 'ACT'),
('2023-08', 'Rol de pago - Agosto', '2023-08-01', '2023-08-31', 'ACT'),
('2023-09', 'Rol de pago - Septiembre', '2023-09-01', '2023-09-30', 'ACT'),
('2023-10', 'Rol de pago - Octubre', '2023-10-01', '2023-10-31', 'ACT'),
('2023-11', 'Rol de pago - Noviembre', '2023-11-01', '2023-11-30', 'ACT'),
('2023-12', 'Rol de pago - Diciembre', '2023-12-01', '2023-12-31', 'ACT'),
('2024-01', 'Rol de pago - Enero', '2024-01-01', '2024-01-31', 'ACT'),
('2024-02', 'Rol de pago - Febrero', '2024-02-01', '2024-02-28', 'ACT'),
('2024-03', 'Rol de pago - Marzo', '2024-03-01', '2024-03-31', 'ACT'),
('2024-04', 'Rol de pago - Abril', '2024-04-01', '2024-04-30', 'ACT'),
('2024-05', 'Rol de pago - Mayo', '2024-05-01', '2024-05-31', 'ACT'),
('2024-06', 'Rol de pago - Junio', '2024-06-01', '2024-06-30', 'ACT'),
('2024-07', 'Rol de pago - Julio', '2024-07-01', '2024-07-31', 'ACT'),
('2024-08', 'Rol de pago - Agosto', '2024-08-01', '2024-08-31', 'ACT'),
('2024-09', 'Rol de pago - Septiembre', '2024-09-01', '2024-09-30', 'ACT'),
('2024-10', 'Rol de pago - Octubre', '2024-10-01', '2024-10-31', 'ACT'),
('2024-11', 'Rol de pago - Noviembre', '2024-11-01', '2024-11-30', 'ACT'),
('2024-12', 'Rol de pago - Diciembre', '2024-12-01', '2024-12-31', 'ACT');

-- Reactivar verificación de llaves foráneas
SET FOREIGN_KEY_CHECKS = 1;