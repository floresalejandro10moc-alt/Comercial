using Dapper;
using SDV.Model.Entities;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;

namespace SDV.DataAccess.Repositories
{
    public class NominaRepository : RepositoryBase
    {

        // --- LECTURA DE CATÁLOGOS ---
        public async Task<IEnumerable<Bonificacion>> GetBonificacionesAsync()
        {
            using (var db = GetConnection())
            {
                var sql = "SELECT id_Bonificacion AS Id, bon_Descripcion AS Descripcion, bon_Valor AS Valor FROM bonificaciones WHERE ESTADO_BON = 'ACT'";
                return await db.QueryAsync<Bonificacion>(sql);
            }
        }

        public async Task<IEnumerable<Descuento>> GetDescuentosAsync()
        {
            using (var db = GetConnection())
            {
                var sql = "SELECT id_Descuento AS Id, des_Descripcion AS Descripcion, des_Valor AS Valor FROM descuentos WHERE ESTADO_DES = 'ACT'";
                return await db.QueryAsync<Descuento>(sql);
            }
        }

        // --- NUEVO: OBTENER HISTORIAL (READ) ---
        public async Task<IEnumerable<PagxEmp>> GetHistorialRolesAsync()
        {
            using (var db = GetConnection())
            {
                var sql = @"
                    SELECT 
                        p.id_Pago AS IdPago,
                        p.id_Empleado AS IdEmpleado,
                        CONCAT(e.emp_Nombre1, ' ', e.emp_Apellido1) AS NombreEmpleado,
                        p.emp_Sueldo AS EmpSueldo,
                        p.emp_Bonificaciones AS EmpBonificaciones,
                        p.emp_Descuentos AS EmpDescuentos,
                        p.emp_Valor_Neto AS EmpValorNeto,
                        p.ESTADO_PxE AS EstadoPxE
                    FROM pagxemp p
                    INNER JOIN empleados e ON p.id_Empleado = e.id_Empleado
                    WHERE p.ESTADO_PxE != 'ANU'  -- CAMBIO: Ocultar anulados
                    ORDER BY p.id_Pago DESC, e.emp_Apellido1 ASC";

                return await db.QueryAsync<PagxEmp>(sql);
            }
        }

        // --- NUEVO: RECUPERAR DETALLES PARA EDICIÓN ---
        // --- NominaRepository.cs ---

        public async Task<IEnumerable<BonxEmpxPag>> GetDetallesBonosAsync(string idPago, int idEmpleado)
        {
            using (var db = GetConnection())
            {
                var sql = @"
            SELECT bx.id_Bonificacion AS IdBonificacion, 
                   bx.id_Empleado AS IdEmpleado,   -- FALTABA ESTE
                   bx.id_Pago AS IdPago,           -- FALTABA ESTE
                   bx.bxe_Valor AS BxeValor, 
                   b.bon_Descripcion AS Descripcion 
            FROM bonxempxpag bx
            INNER JOIN bonificaciones b ON bx.id_Bonificacion = b.id_Bonificacion
            WHERE bx.id_Pago = @IdPago AND bx.id_Empleado = @IdEmpleado AND bx.ESTADO_BXE = 'ACT'";
                return await db.QueryAsync<BonxEmpxPag>(sql, new { IdPago = idPago, IdEmpleado = idEmpleado });
            }
        }

        public async Task<IEnumerable<DesxEmpxPag>> GetDetallesDescuentosAsync(string idPago, int idEmpleado)
        {
            using (var db = GetConnection())
            {
                var sql = @"
            SELECT dx.id_Descuento AS IdDescuento, 
                   dx.id_Empleado AS IdEmpleado,   -- FALTABA ESTE
                   dx.id_Pago AS IdPago,           -- FALTABA ESTE
                   dx.dxe_Valor AS DxeValor, 
                   d.des_Descripcion AS Descripcion 
            FROM desxempxpag dx
            INNER JOIN descuentos d ON dx.id_Descuento = d.id_Descuento
            WHERE dx.id_Pago = @IdPago AND dx.id_Empleado = @IdEmpleado AND dx.ESTADO_DXE = 'ACT'";
                return await db.QueryAsync<DesxEmpxPag>(sql, new { IdPago = idPago, IdEmpleado = idEmpleado });
            }
        }

        // --- NUEVO: ELIMINAR LÓGICO (DELETE) ---
        // --- MODIFICADO: ANULACIÓN EN CASCADA ---
        public async Task AnularRolAsync(string idPago, int idEmpleado)
        {
            using (var db = GetConnection())
            {
                db.Open();
                using (var trans = db.BeginTransaction())
                {
                    try
                    {
                        // 1. Anular Cabecera
                        var sqlHead = "UPDATE pagxemp SET ESTADO_PxE = 'ANU' WHERE id_Pago = @IdPago AND id_Empleado = @IdEmpleado";
                        await db.ExecuteAsync(sqlHead, new { IdPago = idPago, IdEmpleado = idEmpleado }, trans);

                        // 2. Anular Bonos asociados
                        var sqlBon = "UPDATE bonxempxpag SET ESTADO_BXE = 'ANU' WHERE id_Pago = @IdPago AND id_Empleado = @IdEmpleado";
                        await db.ExecuteAsync(sqlBon, new { IdPago = idPago, IdEmpleado = idEmpleado }, trans);

                        // 3. Anular Descuentos asociados
                        var sqlDes = "UPDATE desxempxpag SET ESTADO_DXE = 'ANU' WHERE id_Pago = @IdPago AND id_Empleado = @IdEmpleado";
                        await db.ExecuteAsync(sqlDes, new { IdPago = idPago, IdEmpleado = idEmpleado }, trans);

                        trans.Commit();
                    }
                    catch
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }
        //VAlidar si exite ya ese Rol
        public async Task<bool> ExisteRolAsync(string idPago, int idEmpleado)
        {
            using (var db = GetConnection())
            {
                var sql = "SELECT COUNT(*) FROM pagxemp WHERE id_Pago = @IdPago AND id_Empleado = @IdEmpleado AND ESTADO_PxE != 'ANU'";
                int count = await db.ExecuteScalarAsync<int>(sql, new { IdPago = idPago, IdEmpleado = idEmpleado });
                return count > 0;
            }
        }
        // sepa de qué mes es el rol que vas a imprimir
        public async Task<Pago?> GetPagoByIdAsync(string idPago)
        {
            using (var db = GetConnection())
            {
                var sql = @"SELECT id_Pago AS IdPago, 
                           pag_Descripcion AS PagDescripcion, 
                           pag_Fecha_Inicio AS PagFechaInicio, 
                           pag_Fecha_Fin AS PagFechaFin 
                    FROM pagos 
                    WHERE id_Pago = @IdPago";
                // QueryFirstOrDefaultAsync permite que devuelva NULL si no existe
                return await db.QueryFirstOrDefaultAsync<Pago>(sql, new { IdPago = idPago });
            }
        }
        // NominaRepository.cs

        public async Task<bool> InsertarBonificacionAsync(string descripcion, decimal valor)
        {
            using (var db = GetConnection())
            {
                // Generamos un ID simple (ej: B-0021)
                string ultimoId = await db.ExecuteScalarAsync<string>("SELECT MAX(id_Bonificacion) FROM bonificaciones");
                int numero = int.Parse(ultimoId.Split('-')[1]) + 1;
                string nuevoId = $"B-{numero:D4}";

                string sql = "INSERT INTO bonificaciones (id_Bonificacion, bon_Descripcion, bon_Valor, ESTADO_BON) VALUES (@Id, @Desc, @Val, 'ACT')";
                return await db.ExecuteAsync(sql, new { Id = nuevoId, Desc = descripcion, Val = valor }) > 0;
            }
        }

        public async Task<bool> InsertarDescuentoAsync(string descripcion, decimal valor)
        {
            using (var db = GetConnection())
            {
                // Generamos un ID simple (ej: D-0021)
                string ultimoId = await db.ExecuteScalarAsync<string>("SELECT MAX(id_Descuento) FROM descuentos");
                int numero = int.Parse(ultimoId.Split('-')[1]) + 1;
                string nuevoId = $"D-{numero:D4}";

                string sql = "INSERT INTO descuentos (id_Descuento, des_Descripcion, des_Valor, ESTADO_DES) VALUES (@Id, @Desc, @Val, 'ACT')";
                return await db.ExecuteAsync(sql, new { Id = nuevoId, Desc = descripcion, Val = valor }) > 0;
            }
        }
        // NominaRepository.cs

        public async Task<IEnumerable<dynamic>> GetTodasBonificacionesAsync()
        {
            using (var db = GetConnection())
            {
                return await db.QueryAsync("SELECT id_Bonificacion as Id, bon_Descripcion as Descripcion, bon_Valor as Valor FROM bonificaciones WHERE ESTADO_BON = 'ACT'");
            }
        }

        public async Task<IEnumerable<dynamic>> GetTodosDescuentosAsync()
        {
            using (var db = GetConnection())
            {
                return await db.QueryAsync("SELECT id_Descuento as Id, des_Descripcion as Descripcion, des_Valor as Valor FROM descuentos WHERE ESTADO_DES = 'ACT'");
            }
        }

        public async Task<bool> EliminarBonificacionAsync(string id)
        {
            using (var db = GetConnection())
            {
                return await db.ExecuteAsync("UPDATE bonificaciones SET ESTADO_BON = 'INA' WHERE id_Bonificacion = @id", new { id }) > 0;
            }
        }

        public async Task<bool> EliminarDescuentoAsync(string id)
        {
            using (var db = GetConnection())
            {
                return await db.ExecuteAsync("UPDATE descuentos SET ESTADO_DES = 'INA' WHERE id_Descuento = @id", new { id }) > 0;
            }
        }
        public async Task InsertAsync(Empleado e)
        {
            using (var db = GetConnection())
            {
                // 1. ABRIR LA CONEXIÓN MANUALMENTE
                db.Open();

                // 2. ESTABLECER EL USUARIO (Aquí es donde pones el código)
                // Puedes pasar el nombre del usuario que inició sesión
                await db.ExecuteAsync("SET @app_user = 'Admin_Alejandro'");

                // 3. TU LÓGICA NORMAL DE SIEMPRE
                var parameters = new { /* tus parámetros */ };
                await db.ExecuteAsync("sp_Empleado_Insertar", parameters, commandType: CommandType.StoredProcedure);
            }
        }
        // --- GUARDADO TRANSACCIONAL (CREATE / UPDATE) ---
        public async Task GuardarNominaCompletaAsync(Pago pago, PagxEmp detalle, List<BonxEmpxPag> listaBonos, List<DesxEmpxPag> listaDescuentos, string asientoTexto)
        {
            using (var db = GetConnection())
            {
                db.Open(); // Cambio a Sincrónico para evitar error de IDbConnection
                using (var trans = db.BeginTransaction())
                {
                    try
                    {
                        // 1. Guardar/Asegurar Cabecera de PAGOS
                        var existePago = await db.ExecuteScalarAsync<int>(
                            "SELECT COUNT(*) FROM pagos WHERE id_Pago = @IdPago", new { IdPago = pago.IdPago }, trans);

                        if (existePago == 0)
                        {
                            var sqlPago = @"INSERT INTO pagos (id_Pago, pag_Descripcion, pag_Fecha_Inicio, pag_Fecha_Fin, ESTADO_PAG) 
                                    VALUES (@IdPago, @PagDescripcion, @PagFechaInicio, @PagFechaFin, 'ACT')";
                            await db.ExecuteAsync(sqlPago, pago, trans);
                        }

                        // 2. Guardar Detalle de Pago por Empleado (UPSERT)
                        var sqlDetalle = @"INSERT INTO pagxemp (id_Pago, id_Empleado, emp_Sueldo, emp_Bonificaciones, emp_Descuentos, emp_Valor_Neto, ESTADO_PxE)
                                   VALUES (@IdPago, @IdEmpleado, @EmpSueldo, @EmpBonificaciones, @EmpDescuentos, @EmpValorNeto, @EstadoPxE)
                                   ON DUPLICATE KEY UPDATE 
                                   emp_Bonificaciones = @EmpBonificaciones, 
                                   emp_Descuentos = @EmpDescuentos, 
                                   emp_Valor_Neto = @EmpValorNeto,
                                   ESTADO_PxE = @EstadoPxE";
                        await db.ExecuteAsync(sqlDetalle, detalle, trans);

                        // 3. Limpieza de detalles antiguos
                        await db.ExecuteAsync("DELETE FROM bonxempxpag WHERE id_Pago = @IdPago AND id_Empleado = @IdEmpleado", new { detalle.IdPago, detalle.IdEmpleado }, trans);
                        await db.ExecuteAsync("DELETE FROM desxempxpag WHERE id_Pago = @IdPago AND id_Empleado = @IdEmpleado", new { detalle.IdPago, detalle.IdEmpleado }, trans);

                        // 4. Insertar Nuevos Bonos
                        if (listaBonos != null && listaBonos.Any())
                        {
                            var sqlBono = @"INSERT INTO bonxempxpag (id_Bonificacion, id_Empleado, id_Pago, bxe_Fecha, bxe_Valor, ESTADO_BXE)
                                    VALUES (@IdBonificacion, @IdEmpleado, @IdPago, @BxeFecha, @BxeValor, 'ACT')";
                            await db.ExecuteAsync(sqlBono, listaBonos, trans);
                        }

                        // 5. Insertar Nuevos Descuentos
                        if (listaDescuentos != null && listaDescuentos.Any())
                        {
                            var sqlDesc = @"INSERT INTO desxempxpag (id_Descuento, id_Empleado, id_Pago, dxe_Fecha, dxe_Valor, ESTADO_DXE)
                                    VALUES (@IdDescuento, @IdEmpleado, @IdPago, @DxeFecha, @DxeValor, 'ACT')";
                            await db.ExecuteAsync(sqlDesc, listaDescuentos, trans);
                        }

                        // 6. Generar Asiento Contable Real (Solo si es Aprobado)
                        // 6. Generar Asiento Contable Real (Solo si es Aprobado)
                        if (detalle.EstadoPxE == "APR")
                        {
                            string idAsientoUnico = "ASI-" + DateTime.Now.Ticks.ToString().Substring(10);

                            // Cálculos contables
                            decimal iessPersonal = Math.Round(detalle.EmpSueldo * 0.0945m, 2);
                            decimal otrosDescuentos = detalle.EmpDescuentos - iessPersonal; // El resto de descuentos que no son IESS
                            decimal totalGastosEmpresa = detalle.EmpSueldo + detalle.EmpBonificaciones; // Lo que realmente le cuesta a la empresa

                            // A. Insertar Cabecera del Asiento
                            // El monto total del asiento debe ser la suma de todos los ingresos (Sueldo + Bonos)
                            await db.ExecuteAsync(@"INSERT INTO asientos (ID_ASIENTOCONTABLE, ASI_DESCRIPCION, ASI_TOTAL_DEBE, ASI_TOTAL_HABER, ASI_USERID, ASI_ESTADOASIENTO)
                           VALUES (@IdAsiento, @Desc, @Monto, @Monto, 'SISTEMA', 'ACT')",
                                                   new
                                                   {
                                                       IdAsiento = idAsientoUnico,
                                                       Desc = $"Nómina: {detalle.NombreEmpleado} - Periodo {pago.IdPago}",
                                                       Monto = totalGastosEmpresa
                                                   }, trans);

                            // --- PARTIDAS DEL DEBE (GASTOS) ---

                            // 1. Gasto Sueldos (Código script: 5.3.01.01.01)
                            await db.ExecuteAsync(@"INSERT INTO cuentasxasiento (ID_ASIENTOCONTABLE, ID_CODIGOCUENTA, CXA_MONTODEBE, CXA_MONTOHABER, CXA_DESCRIPCION) 
                           VALUES (@IdAsiento, '5.3.01.01.01', @Val, 0, 'Sueldo Unificado')",
                                                   new { IdAsiento = idAsientoUnico, Val = detalle.EmpSueldo }, trans);

                            // 2. Gasto Bonificaciones (Código script: 5.3.01.01.04)
                            if (detalle.EmpBonificaciones > 0)
                            {
                                await db.ExecuteAsync(@"INSERT INTO cuentasxasiento (ID_ASIENTOCONTABLE, ID_CODIGOCUENTA, CXA_MONTODEBE, CXA_MONTOHABER, CXA_DESCRIPCION) 
                               VALUES (@IdAsiento, '5.3.01.01.04', @Val, 0, 'Bonificaciones/Comisiones')",
                                                       new { IdAsiento = idAsientoUnico, Val = detalle.EmpBonificaciones }, trans);
                            }

                            // --- PARTIDAS DEL HABER (PAGOS Y OBLIGACIONES) ---

                            // 3. IESS por Pagar (Código script: 2.1.07.03.01)
                            await db.ExecuteAsync(@"INSERT INTO cuentasxasiento (ID_ASIENTOCONTABLE, ID_CODIGOCUENTA, CXA_MONTODEBE, CXA_MONTOHABER, CXA_DESCRIPCION) 
                           VALUES (@IdAsiento, '2.1.07.03.01', 0, @Val, 'Aporte IESS Personal')",
                                                   new { IdAsiento = idAsientoUnico, Val = iessPersonal }, trans);

                            // 4. Otros Descuentos / Cuentas por Pagar (Código script: 2.1.09.02.01)
                            if (otrosDescuentos > 0)
                            {
                                await db.ExecuteAsync(@"INSERT INTO cuentasxasiento (ID_ASIENTOCONTABLE, ID_CODIGOCUENTA, CXA_MONTODEBE, CXA_MONTOHABER, CXA_DESCRIPCION) 
                               VALUES (@IdAsiento, '2.1.09.02.01', 0, @Val, 'Otros Descuentos/Retenciones')",
                                                       new { IdAsiento = idAsientoUnico, Val = otrosDescuentos }, trans);
                            }

                            // 5. Bancos - Salida de dinero real (Código script: 1.1.01.02.01)
                            await db.ExecuteAsync(@"INSERT INTO cuentasxasiento (ID_ASIENTOCONTABLE, ID_CODIGOCUENTA, CXA_MONTODEBE, CXA_MONTOHABER, CXA_DESCRIPCION) 
                           VALUES (@IdAsiento, '1.1.01.02.01', 0, @Val, 'Pago Neto a Empleado')",
                                                   new { IdAsiento = idAsientoUnico, Val = detalle.EmpValorNeto }, trans);
                        }

                        trans.Commit(); // Cambio a Sincrónico
                    }
                    catch (Exception)
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }
    }
}