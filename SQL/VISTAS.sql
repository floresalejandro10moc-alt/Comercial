-- MySQL dump 10.13  Distrib 8.4.7, for Win64 (x86_64)
--
-- Host: localhost    Database: sistemaventassdv
-- ------------------------------------------------------
-- Server version	8.4.7

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `v_empleados_listado`
--

DROP TABLE IF EXISTS `v_empleados_listado`;
/*!50001 DROP VIEW IF EXISTS `v_empleados_listado`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_empleados_listado` AS SELECT 
 1 AS `id_Empleado`,
 1 AS `emp_Cedula`,
 1 AS `emp_Apellido1`,
 1 AS `emp_Apellido2`,
 1 AS `emp_Nombre1`,
 1 AS `emp_Nombre2`,
 1 AS `NombreCompleto`,
 1 AS `emp_Email`,
 1 AS `emp_Sexo`,
 1 AS `emp_FechaNacimiento`,
 1 AS `emp_Sueldo`,
 1 AS `Departamento`,
 1 AS `Cargo`,
 1 AS `id_Departamento`,
 1 AS `id_Rol`,
 1 AS `ESTADO_EMP`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'sistemaventassdv'
--

--
-- Dumping routines for database 'sistemaventassdv'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_Catalogo_ListarDepartamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Catalogo_ListarDepartamentos`()
BEGIN
    SELECT id_Departamento AS Id, dep_Nombre AS Nombre FROM Departamentos WHERE ESTADO_DEP='ACT';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Catalogo_ListarRoles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Catalogo_ListarRoles`()
BEGIN
    SELECT id_Rol AS Id, rol_Descripcion AS Nombre FROM Roles WHERE ESTADO_ROL='ACT';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Empleado_Actualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Empleado_Actualizar`(
    IN p_IdEmpleado INT,
    IN p_Cedula CHAR(10),
    IN p_Apellido1 CHAR(30),
    IN p_Apellido2 CHAR(30),
    IN p_Nombre1 CHAR(30),
    IN p_Nombre2 CHAR(30),
    IN p_Sexo CHAR(1),
    IN p_FechaNacimiento DATE,
    IN p_Sueldo DECIMAL(7,2),
    IN p_Mail CHAR(40),
    IN p_IdDepartamento CHAR(7),
    IN p_IdRol CHAR(7),
    IN p_Estado CHAR(3)
)
BEGIN
    UPDATE Empleados SET
        emp_Cedula = p_Cedula,
        emp_Apellido1 = p_Apellido1,
        emp_Apellido2 = p_Apellido2,
        emp_Nombre1 = p_Nombre1,
        emp_Nombre2 = p_Nombre2,
        emp_Sexo = p_Sexo,
        emp_FechaNacimiento = p_FechaNacimiento,
        emp_Sueldo = p_Sueldo,
        emp_Mail = p_Mail,
        id_Departamento = p_IdDepartamento,
        id_Rol = p_IdRol,
        ESTADO_EMP = p_Estado
    WHERE id_Empleado = p_IdEmpleado;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Empleado_Buscar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Empleado_Buscar`(
    IN p_Texto VARCHAR(100)
)
BEGIN
    SELECT e.*, d.dep_Nombre AS NombreDepartamento, r.rol_Descripcion AS NombreCargo
    FROM Empleados e
    INNER JOIN Departamentos d ON e.id_Departamento = d.id_Departamento
    INNER JOIN Roles r ON e.id_Rol = r.id_Rol
    WHERE e.ESTADO_EMP = 'ACT' 
    AND (
        e.emp_Nombre1 LIKE p_Texto OR 
        e.emp_Apellido1 LIKE p_Texto OR 
        e.emp_Cedula LIKE p_Texto OR 
        r.rol_Descripcion LIKE p_Texto
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Empleado_ContarTotal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Empleado_ContarTotal`()
BEGIN
    SELECT COUNT(*) FROM Empleados WHERE ESTADO_EMP = 'ACT';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Empleado_Eliminar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Empleado_Eliminar`(
    IN p_IdEmpleado INT
)
BEGIN
    UPDATE Empleados SET ESTADO_EMP = 'INA' WHERE id_Empleado = p_IdEmpleado;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Empleado_ExisteCedula` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Empleado_ExisteCedula`(
    IN p_Cedula CHAR(10)
)
BEGIN
    SELECT COUNT(1) FROM Empleados WHERE emp_Cedula = p_Cedula;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Empleado_Insertar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Empleado_Insertar`(
    IN p_Cedula CHAR(10),
    IN p_Apellido1 CHAR(30),
    IN p_Apellido2 CHAR(30),
    IN p_Nombre1 CHAR(30),
    IN p_Nombre2 CHAR(30),
    IN p_Sexo CHAR(1),
    IN p_FechaNacimiento DATE,
    IN p_Sueldo DECIMAL(7,2),
    IN p_Mail CHAR(40),
    IN p_IdDepartamento CHAR(7),
    IN p_IdRol CHAR(7)
)
BEGIN
    INSERT INTO Empleados (
        emp_Cedula, emp_Apellido1, emp_Apellido2, emp_Nombre1, emp_Nombre2,
        emp_Sexo, emp_FechaNacimiento, emp_Sueldo, emp_Mail,
        id_Departamento, id_Rol, ESTADO_EMP
    ) VALUES (
        p_Cedula, p_Apellido1, p_Apellido2, p_Nombre1, p_Nombre2,
        p_Sexo, p_FechaNacimiento, p_Sueldo, p_Mail,
        p_IdDepartamento, p_IdRol, 'ACT'
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Empleado_ListarPaginado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Empleado_ListarPaginado`(
    IN p_Limit INT,
    IN p_Offset INT
)
BEGIN
    SELECT 
        e.*, 
        d.dep_Nombre AS NombreDepartamento, 
        r.rol_Descripcion AS NombreCargo
    FROM Empleados e
    LEFT JOIN Departamentos d ON e.id_Departamento = d.id_Departamento
    LEFT JOIN Roles r ON e.id_Rol = r.id_Rol
    WHERE e.ESTADO_EMP = 'ACT'
    ORDER BY e.emp_Apellido1 ASC
    LIMIT p_Limit OFFSET p_Offset;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GenerarNominaMasiva` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_GenerarNominaMasiva`(IN anio CHAR(4))
BEGIN
    -- Desactivar verificación de llaves para poder limpiar tablas rápido
    SET FOREIGN_KEY_CHECKS = 0;
    
    -- Limpieza total de tablas de nómina
    TRUNCATE TABLE BonxEmpxPag;
    TRUNCATE TABLE DesxEmpxPag;
    TRUNCATE TABLE PagxEmp;
    
    -- Reactivar verificación
    SET FOREIGN_KEY_CHECKS = 1;

    -- A. INSERTAR CABECERAS (PagxEmp)
    -- Genera registros para todos los meses excepto Diciembre (12)
    INSERT INTO PagxEmp (id_Pago, id_Empleado, emp_Sueldo, emp_Bonificaciones, emp_Descuentos, emp_Valor_Neto, ESTADO_PxE)
    SELECT 
        p.id_Pago,
        e.id_Empleado,
        e.emp_Sueldo,
        0.00, 
        0.00, 
        0.00, 
        'PEN' 
    FROM Pagos p
    CROSS JOIN Empleados e
    WHERE p.id_Pago LIKE CONCAT(anio, '-%') 
      AND RIGHT(p.id_Pago, 2) <> '12'
      AND e.ESTADO_EMP = 'ACT';

    -- B. GENERAR DESCUENTOS (IESS 9.45%)
    INSERT INTO DesxEmpxPag (id_Descuento, id_Empleado, id_Pago, dxe_Fecha, dxe_Valor, ESTADO_DXE)
    SELECT 
        'D-0002', -- Código D-0002 es Aporte IESS
        pe.id_Empleado,
        pe.id_Pago,
        p.pag_Fecha_Fin, 
        ROUND(pe.emp_Sueldo * 0.0945, 2), 
        'VAL'
    FROM PagxEmp pe
    INNER JOIN Pagos p ON pe.id_Pago = p.id_Pago;

    -- C. GENERAR BONIFICACIONES (Bono Puntualidad Fijo $50)
    INSERT INTO BonxEmpxPag (id_Bonificacion, id_Empleado, id_Pago, bxe_Fecha, bxe_Valor, ESTADO_BXE)
    SELECT 
        'B-0003', -- Código B-0003 es Bono Puntualidad
        pe.id_Empleado,
        pe.id_Pago,
        p.pag_Fecha_Fin,
        50.00, 
        'VAL'
    FROM PagxEmp pe
    INNER JOIN Pagos p ON pe.id_Pago = p.id_Pago;

    -- D. ACTUALIZAR TOTALES EN LA CABECERA
    UPDATE PagxEmp pe
    SET 
        emp_Bonificaciones = (
            SELECT IFNULL(SUM(b.bxe_Valor), 0) 
            FROM BonxEmpxPag b 
            WHERE b.id_Empleado = pe.id_Empleado AND b.id_Pago = pe.id_Pago
        ),
        emp_Descuentos = (
            SELECT IFNULL(SUM(d.dxe_Valor), 0) 
            FROM DesxEmpxPag d 
            WHERE d.id_Empleado = pe.id_Empleado AND d.id_Pago = pe.id_Pago
        );

    -- E. CALCULAR NETO A PAGAR FINAL
    UPDATE PagxEmp
    SET emp_Valor_Neto = emp_Sueldo + emp_Bonificaciones - emp_Descuentos;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Nomina_GenerarRolIndividual` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_Nomina_GenerarRolIndividual`(
    IN p_IdEmpleado INT,
    IN p_FechaCorte DATE -- Ejemplo: '2025-12-18'
)
BEGIN
    -- Variables Generales
    DECLARE v_IdPago CHAR(7);           -- Se generará automáticamente (ej. '2025-12')
    DECLARE v_SueldoBase DECIMAL(7,2);
    DECLARE v_DiasTrabajados INT;
    DECLARE v_SueldoProporcional DECIMAL(7,2);
    
    -- Variables para totales
    DECLARE v_TotalBonos DECIMAL(7,2) DEFAULT 0;
    DECLARE v_TotalDescuentos DECIMAL(7,2) DEFAULT 0;
    DECLARE v_ValorNeto DECIMAL(7,2);
    
    -- Variables temporales para Bonos/Descuentos (quemados para el ejemplo)
    DECLARE v_ValB1 DECIMAL(7,2); DECLARE v_ValB2 DECIMAL(7,2); DECLARE v_ValB3 DECIMAL(7,2);
    DECLARE v_ValD1 DECIMAL(7,2); DECLARE v_ValD2 DECIMAL(7,2); DECLARE v_ValD3 DECIMAL(7,2);

    -- Manejo de Errores General
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL; -- Pasa el error a la aplicación (C#)
    END;

    START TRANSACTION;

    -- 1. Generar ID de Pago y Calcular Días
    -- Formato esperado 'YYYY-MM'
    SET v_IdPago = DATE_FORMAT(p_FechaCorte, '%Y-%m');
    SET v_DiasTrabajados = DAY(p_FechaCorte);

    -- 2. VALIDACIÓN CRÍTICA: ¿Ya existe el rol?
    -- Si existe, lanzamos un error personalizado. NO BORRAMOS NADA.
    IF EXISTS (SELECT 1 FROM PagxEmp WHERE id_Empleado = p_IdEmpleado AND id_Pago = v_IdPago) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERR_DUPLICADO: Ya existe un rol generado para este empleado en este mes.';
    END IF;

    -- 3. Validar existencia del Empleado y obtener Sueldo Base
    SELECT emp_Sueldo INTO v_SueldoBase 
    FROM Empleados 
    WHERE id_Empleado = p_IdEmpleado;

    IF v_SueldoBase IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El Empleado no existe.';
    END IF;

    -- 4. Validar que el periodo (Mes) exista en la tabla Pagos
    -- Asumimos que la tabla Pagos debe tener creado el mes '2025-12' antes de procesar
    IF NOT EXISTS (SELECT 1 FROM Pagos WHERE id_Pago = v_IdPago) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El periodo contable (Mes) no está abierto o no existe.';
    END IF;

    -- 5. Lógica de Prorrateo (Sueldo Proporcional)
    -- Asumiendo mes comercial de 30 días.
    -- Si la fecha es 18, paga (Sueldo / 30) * 18.
    SET v_SueldoProporcional = (v_SueldoBase / 30) * v_DiasTrabajados;

    -- 6. Obtener Bonos (Aquí podrías decidir si los bonos también se prorratean o son fijos)
    -- Para este ejemplo, los mantenemos fijos según tu lógica anterior.
    SELECT bon_Valor INTO v_ValB1 FROM Bonificaciones WHERE id_Bonificacion = 'B-0001';
    SELECT bon_Valor INTO v_ValB2 FROM Bonificaciones WHERE id_Bonificacion = 'B-0002';
    SELECT bon_Valor INTO v_ValB3 FROM Bonificaciones WHERE id_Bonificacion = 'B-0003';
    
    SET v_TotalBonos = IFNULL(v_ValB1,0) + IFNULL(v_ValB2,0) + IFNULL(v_ValB3,0);

    -- 7. Obtener Descuentos
    SELECT des_Valor INTO v_ValD1 FROM Descuentos WHERE id_Descuento = 'D-0001';
    SELECT des_Valor INTO v_ValD2 FROM Descuentos WHERE id_Descuento = 'D-0002';
    SELECT des_Valor INTO v_ValD3 FROM Descuentos WHERE id_Descuento = 'D-0003';

    SET v_TotalDescuentos = IFNULL(v_ValD1,0) + IFNULL(v_ValD2,0) + IFNULL(v_ValD3,0);

    -- 8. Calcular Neto (Usando el Sueldo Proporcional)
    SET v_ValorNeto = v_SueldoProporcional + v_TotalBonos - v_TotalDescuentos;

    -- 9. Insertar Cabecera (PagxEmp) - Notar que usamos v_SueldoProporcional
    INSERT INTO PagxEmp (
        id_Pago, id_Empleado, emp_Sueldo, emp_Bonificaciones, 
        emp_Descuentos, emp_Valor_Neto, ESTADO_PxE
    ) VALUES (
        v_IdPago, p_IdEmpleado, v_SueldoProporcional, v_TotalBonos, 
        v_TotalDescuentos, v_ValorNeto, 'PEN'
    );

    -- 10. Insertar Detalles
    INSERT INTO BonxEmpxPag (id_Bonificacion, id_Empleado, id_Pago, bxe_Fecha, bxe_Valor, ESTADO_BXE)
    VALUES 
    ('B-0001', p_IdEmpleado, v_IdPago, p_FechaCorte, v_ValB1, 'ACT'),
    ('B-0002', p_IdEmpleado, v_IdPago, p_FechaCorte, v_ValB2, 'ACT'),
    ('B-0003', p_IdEmpleado, v_IdPago, p_FechaCorte, v_ValB3, 'ACT');

    INSERT INTO DesxEmpxPag (id_Descuento, id_Empleado, id_Pago, dxe_Fecha, dxe_Valor, ESTADO_DXE)
    VALUES 
    ('D-0001', p_IdEmpleado, v_IdPago, p_FechaCorte, v_ValD1, 'ACT'),
    ('D-0002', p_IdEmpleado, v_IdPago, p_FechaCorte, v_ValD2, 'ACT'),
    ('D-0003', p_IdEmpleado, v_IdPago, p_FechaCorte, v_ValD3, 'ACT');

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_empleados_listado`
--

/*!50001 DROP VIEW IF EXISTS `v_empleados_listado`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `v_empleados_listado` AS select `e`.`id_Empleado` AS `id_Empleado`,`e`.`emp_Cedula` AS `emp_Cedula`,`e`.`emp_Apellido1` AS `emp_Apellido1`,`e`.`emp_Apellido2` AS `emp_Apellido2`,`e`.`emp_Nombre1` AS `emp_Nombre1`,`e`.`emp_Nombre2` AS `emp_Nombre2`,concat(`e`.`emp_Apellido1`,' ',ifnull(`e`.`emp_Apellido2`,''),' ',`e`.`emp_Nombre1`,' ',ifnull(`e`.`emp_Nombre2`,'')) AS `NombreCompleto`,`e`.`emp_Mail` AS `emp_Email`,`e`.`emp_Sexo` AS `emp_Sexo`,`e`.`emp_FechaNacimiento` AS `emp_FechaNacimiento`,`e`.`emp_Sueldo` AS `emp_Sueldo`,`d`.`dep_Nombre` AS `Departamento`,`r`.`rol_Descripcion` AS `Cargo`,`e`.`id_Departamento` AS `id_Departamento`,`e`.`id_Rol` AS `id_Rol`,`e`.`ESTADO_EMP` AS `ESTADO_EMP` from ((`empleados` `e` left join `departamentos` `d` on((`e`.`id_Departamento` = `d`.`id_Departamento`))) left join `roles` `r` on((`e`.`id_Rol` = `r`.`id_Rol`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-02 14:50:24
