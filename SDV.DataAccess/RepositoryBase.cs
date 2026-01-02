using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using Microsoft.Extensions.Configuration; // Para leer el JSON
using System.IO;

namespace SDV.DataAccess
{
    public abstract class RepositoryBase
    {
        // Cambiamos a readonly y el nombre por convención
        protected readonly string _connectionString;

        public RepositoryBase()
        {
            // 1. Esto busca el archivo appsettings.json en tu carpeta del proyecto
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);

            IConfiguration configuration = builder.Build();

            // 2. Trae la conexión que pusimos en el JSON
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        // Este método sigue igual, así que tus otros archivos no fallarán
        protected IDbConnection GetConnection() => new MySqlConnection(_connectionString);

        static RepositoryBase()
        {
            // Mantenemos esto porque es vital para tus nombres con guiones bajos
            DefaultTypeMap.MatchNamesWithUnderscores = true;
        }
    }
}