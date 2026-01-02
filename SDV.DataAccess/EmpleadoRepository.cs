using Dapper;
using SDV.Model.DTOs; // Asumo que ItemCatalogo está aquí o en Entities
using SDV.Model.Entities;
using System.Collections.Generic;
using System.Data; // Necesario para CommandType
using System.Threading.Tasks;

namespace SDV.DataAccess.Repositories
{
    public class EmpleadoRepository : RepositoryBase
    {
        // 1. OBTENER PAGINADO (Llama a sp_Empleado_ListarPaginado y sp_Empleado_ContarTotal)
        public async Task<(IEnumerable<Empleado>, int)> GetPaginadoAsync(int pagina, int cantidad)
        {
            using (var db = GetConnection())
            {
                int saltar = (pagina - 1) * cantidad;

                // Parámetros para el SP de listado
                var parameters = new { p_Limit = cantidad, p_Offset = saltar };

                // Llamada al SP de listado
                var data = await db.QueryAsync<Empleado>(
                    "sp_Empleado_ListarPaginado",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                // Llamada al SP de conteo (ExecuteScalar para obtener un valor simple)
                var total = await db.ExecuteScalarAsync<int>(
                    "sp_Empleado_ContarTotal",
                    commandType: CommandType.StoredProcedure
                );

                return (data, total);
            }
        }

        // 2. INSERTAR (Llama a sp_Empleado_Insertar)
        public async Task InsertAsync(Empleado e)
        {
            using (var db = GetConnection())
            {
                // Mapeo explícito de propiedades C# a parámetros del SP MySQL
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

                await db.ExecuteAsync(
                    "sp_Empleado_Insertar",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );
            }
        }

        // 3. ACTUALIZAR (Llama a sp_Empleado_Actualizar)
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
                    p_Estado = e.EstadoEmp // Asumiendo que esta propiedad existe en tu modelo, si no, usa "ACT"
                };

                await db.ExecuteAsync(
                    "sp_Empleado_Actualizar",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );
            }
        }

        // 4. CATALOGO DE ROLES (Llama a sp_Catalogo_ListarRoles)
        public async Task<IEnumerable<ItemCatalogo>> GetRolesAsync()
        {
            using (var db = GetConnection())
            {
                return await db.QueryAsync<ItemCatalogo>(
                    "sp_Catalogo_ListarRoles",
                    commandType: CommandType.StoredProcedure
                );
            }
        }

        // 5. CATALOGO DE DEPARTAMENTOS (Llama a sp_Catalogo_ListarDepartamentos)
        public async Task<IEnumerable<ItemCatalogo>> GetDepartamentosAsync()
        {
            using (var db = GetConnection())
            {
                return await db.QueryAsync<ItemCatalogo>(
                    "sp_Catalogo_ListarDepartamentos",
                    commandType: CommandType.StoredProcedure
                );
            }
        }

        // 6. ELIMINAR (Llama a sp_Empleado_Eliminar)
        public async Task DeleteAsync(int id)
        {
            using (var db = GetConnection())
            {
                await db.ExecuteAsync(
                    "sp_Empleado_Eliminar",
                    new { p_IdEmpleado = id },
                    commandType: CommandType.StoredProcedure
                );
            }
        }

        // 7. EXISTE CÉDULA (Llama a sp_Empleado_ExisteCedula)
        public async Task<bool> ExisteCedulaAsync(string cedula)
        {
            using (var connection = GetConnection())
            {
                var cantidad = await connection.ExecuteScalarAsync<int>(
                    "sp_Empleado_ExisteCedula",
                    new { p_Cedula = cedula },
                    commandType: CommandType.StoredProcedure
                );

                return cantidad > 0;
            }
        }

        // 8. BUSCAR (Llama a sp_Empleado_Buscar)
        public async Task<IEnumerable<Empleado>> BuscarAsync(string texto)
        {
            using (var db = GetConnection())
            {
                // Concatenamos los % aquí en C# antes de enviarlo al SP que usa LIKE
                var parameters = new { p_Texto = $"%{texto}%" };

                return await db.QueryAsync<Empleado>(
                    "sp_Empleado_Buscar",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );
            }
        }

        // 9. GET ALL (Compatibilidad, reutiliza paginación)
       
        public async Task<IEnumerable<Empleado>> GetAllAsync()
        {
            using (var db = GetConnection())
            {
                // Hacemos un JOIN con la tabla Roles para sacar la descripción del cargo
                string sql = @"SELECT e.id_Empleado AS IdEmpleado, 
                              e.emp_Cedula AS EmpCedula, 
                              e.emp_Nombre1 AS EmpNombre1, 
                              e.emp_Apellido1 AS EmpApellido1, 
                              e.emp_Sueldo AS EmpSueldo,
                              r.rol_Descripcion AS EmpCargo -- Traemos el nombre del ROL como CARGO
                       FROM Empleados e
                       INNER JOIN Roles r ON e.id_Rol = r.id_Rol
                       WHERE e.ESTADO_EMP = 'ACT'";

                return await db.QueryAsync<Empleado>(sql);
            }
        }
    }
}