using Dapper;
using SDV.Model.DTOs;
using SDV.Model.Entities;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SDV.DataAccess.Repositories
{
    public class EmpleadoRepository : RepositoryBase
    {
        // 1. OBTENER PAGINADO
        public async Task<(IEnumerable<Empleado>, int)> GetPaginadoAsync(int pagina, int cantidad)
        {
            using (var db = GetConnection())
            {
                int saltar = (pagina - 1) * cantidad;
                var parameters = new { p_Limit = cantidad, p_Offset = saltar };

                var data = await db.QueryAsync<Empleado>(
                    "sp_Empleado_ListarPaginado",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                var total = await db.ExecuteScalarAsync<int>(
                    "sp_Empleado_ContarTotal",
                    commandType: CommandType.StoredProcedure
                );

                return (data, total);
            }
        }

        // 2. INSERTAR
        public async Task InsertAsync(Empleado e)
        {
            using (var db = GetConnection())
            {
                var parameters = new
                {
                    p_Cedula = e.EmpCedula,
                    p_Apellido1 = e.EmpApellido1,
                    p_Apellido2 = e.EmpApellido2,
                    p_Nombre1 = e.EmpNombre1,
                    p_Nombre2 = e.EmpNombre2,
                    p_Sexo = e.EmpSexo,
                    p_FechaNacimiento = e.EmpFechaNacimiento,
                    p_Sueldo = e.EmpSueldo,
                    p_Mail = e.EmpMail,
                    p_IdDepartamento = e.IdDepartamento,
                    p_IdRol = e.IdRol
                };

                await db.ExecuteAsync("sp_Empleado_Insertar", parameters, commandType: CommandType.StoredProcedure);
            }
        }

        // 3. ACTUALIZAR
        public async Task UpdateAsync(Empleado e)
        {
            using (var db = GetConnection())
            {
                var parameters = new
                {
                    p_IdEmpleado = e.IdEmpleado,
                    p_Cedula = e.EmpCedula,
                    p_Apellido1 = e.EmpApellido1,
                    p_Apellido2 = e.EmpApellido2,
                    p_Nombre1 = e.EmpNombre1,
                    p_Nombre2 = e.EmpNombre2,
                    p_Sexo = e.EmpSexo,
                    p_FechaNacimiento = e.EmpFechaNacimiento,
                    p_Sueldo = e.EmpSueldo,
                    p_Mail = e.EmpMail,
                    p_IdDepartamento = e.IdDepartamento,
                    p_IdRol = e.IdRol,
                    p_Estado = e.EstadoEmp
                };

                await db.ExecuteAsync("sp_Empleado_Actualizar", parameters, commandType: CommandType.StoredProcedure);
            }
        }

        // 4. CATALOGO DE ROLES
        public async Task<IEnumerable<ItemCatalogo>> GetRolesAsync()
        {
            using (var db = GetConnection())
            {
                return await db.QueryAsync<ItemCatalogo>("sp_Catalogo_ListarRoles", commandType: CommandType.StoredProcedure);
            }
        }

        // 5. CATALOGO DE DEPARTAMENTOS
        public async Task<IEnumerable<ItemCatalogo>> GetDepartamentosAsync()
        {
            using (var db = GetConnection())
            {
                return await db.QueryAsync<ItemCatalogo>("sp_Catalogo_ListarDepartamentos", commandType: CommandType.StoredProcedure);
            }
        }

        // 6. ELIMINAR
        public async Task DeleteAsync(int id)
        {
            using (var db = GetConnection())
            {
                await db.ExecuteAsync("sp_Empleado_Eliminar", new { p_IdEmpleado = id }, commandType: CommandType.StoredProcedure);
            }
        }

        // 7. EXISTE CÉDULA
        public async Task<bool> ExisteCedulaAsync(string cedula)
        {
            using (var connection = GetConnection())
            {
                var cantidad = await connection.ExecuteScalarAsync<int>("sp_Empleado_ExisteCedula", new { p_Cedula = cedula }, commandType: CommandType.StoredProcedure);
                return cantidad > 0;
            }
        }

        // 8. BUSCAR
        public async Task<IEnumerable<Empleado>> BuscarAsync(string texto)
        {
            using (var db = GetConnection())
            {
                var parameters = new { p_Texto = $"%{texto}%" };
                return await db.QueryAsync<Empleado>("sp_Empleado_Buscar", parameters, commandType: CommandType.StoredProcedure);
            }
        }

        // 9. GET ALL (SQL Directo)
        public async Task<IEnumerable<Empleado>> GetAllAsync()
        {
            using (var db = GetConnection())
            {
                // Tablas en minúsculas: empleados, roles
                string sql = @"SELECT e.id_Empleado AS IdEmpleado, 
                                      e.emp_Cedula AS EmpCedula, 
                                      e.emp_Nombre1 AS EmpNombre1, 
                                      e.emp_Apellido1 AS EmpApellido1, 
                                      e.emp_Sueldo AS EmpSueldo,
                                      r.rol_Descripcion AS EmpCargo 
                               FROM empleados e
                               INNER JOIN roles r ON e.id_Rol = r.id_Rol
                               WHERE e.ESTADO_EMP = 'ACT'";

                return await db.QueryAsync<Empleado>(sql);
            }
        }
    }
}