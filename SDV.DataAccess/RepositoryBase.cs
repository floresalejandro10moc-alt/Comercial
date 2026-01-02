using Dapper;
using MySql.Data.MySqlClient;
using System.Data;

namespace SDV.DataAccess
{
    public abstract class RepositoryBase
    {
        // Reemplaza 'toor' con tu contraseña real si es diferente
        protected string ConnectionString = "Server=localhost;Port=3310;Database=SistemaVentasSDV;Uid=root;Pwd=toor;";

        protected IDbConnection GetConnection() => new MySqlConnection(ConnectionString);

        static RepositoryBase()
        {
            // Esto es vital para que Dapper entienda los guiones bajos de la BD
            DefaultTypeMap.MatchNamesWithUnderscores = true;
        }
    }
}
// <--- ¡IMPORTANTE! Asegúrate de que esta última llave exista.