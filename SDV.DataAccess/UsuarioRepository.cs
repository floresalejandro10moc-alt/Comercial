using Dapper;
using SDV.Model.Entities;
using System.Threading.Tasks;

namespace SDV.DataAccess.Repositories
{
    public class UsuarioRepository : RepositoryBase
    {
        public async Task<(Empleado?, string, string)> LoginAsync(string usuario, string password)
        {
            using (var db = GetConnection())
            {
                var sql = @"
                    SELECT 
                        e.id_Empleado, 
                        e.emp_Nombre1, 
                        e.emp_Apellido1, 
                        e.emp_Mail, 
                        e.emp_Cedula,
                        u.id_Rol,
                        r.rol_descripcion
                    FROM usuarios u
                    LEFT JOIN empleados e ON u.id_Empleado = e.id_Empleado
                    LEFT JOIN roles r ON u.id_Rol = r.id_Rol
                    WHERE u.usr_Login = @User 
                      AND u.usr_Password = @Pass 
                      AND u.ESTADO_USR = 'ACT'";

                var resultado = await db.QueryFirstOrDefaultAsync<dynamic>(sql, new { User = usuario, Pass = password });

                if (resultado == null) return (null, string.Empty, string.Empty);

                // --- MAPEO SEGURO PARA EVITAR ADVERTENCIAS DE NULL ---

                // Usamos 'Convert.ToString' o '??' para asegurar que nunca sea null
                int idEmp = (resultado.id_Empleado != null) ? (int)resultado.id_Empleado : 0;
                string nombre = (string?)resultado.emp_Nombre1 ?? "Usuario";
                string apellido = (string?)resultado.emp_Apellido1 ?? "Sistema";
                string mail = (string?)resultado.emp_Mail ?? "";
                string cedula = (string?)resultado.emp_Cedula ?? "";

                string idRol = (string?)resultado.id_Rol ?? "";
                string descRol = (string?)resultado.rol_descripcion ?? "Rol Desconocido";

                var emp = new Empleado
                {
                    IdEmpleado = idEmp,
                    EmpNombre1 = nombre,
                    EmpApellido1 = apellido,
                    EmpMail = mail,
                    EmpCedula = cedula
                };

                return (emp, idRol, descRol);
            }
        }
    }
}