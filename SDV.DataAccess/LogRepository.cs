using Dapper;
using SDV.Model.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SDV.DataAccess.Repositories
{
    public class LogRepository : RepositoryBase
    {
        public async Task<(IEnumerable<AuditLog>, int)> ObtenerLogsPaginadosAsync(int pagina, int registrosPorPagina, DateTime? fechaFiltro)
        {
            using (var db = GetConnection())
            {
                string condicionFecha = fechaFiltro.HasValue ? "WHERE DATE(fecha_hora) = DATE(@Fecha)" : "";
                int saltar = (pagina - 1) * registrosPorPagina;

                // Tabla 'auditoria_log' en minúsculas. Atributos intactos.
                var sqlDatos = $@"
                    SELECT 
                        id_log           AS IdLog,
                        fecha_hora       AS FechaHora,
                        usuario_sistema  AS Usuario,
                        tabla_afectada   AS Tabla,
                        accion           AS Accion,
                        COALESCE(accion_detallada, datos_nuevos, datos_anteriores, '') AS Detalle,
                        nivel            AS Nivel
                    FROM auditoria_log
                    {condicionFecha}
                    ORDER BY id_log DESC
                    LIMIT @Limit OFFSET @Offset";

                var sqlTotal = $"SELECT COUNT(*) FROM auditoria_log {condicionFecha}";

                var parametros = new
                {
                    Fecha = fechaFiltro,
                    Limit = registrosPorPagina,
                    Offset = saltar
                };

                var datos = await db.QueryAsync<AuditLog>(sqlDatos, parametros);
                var total = await db.ExecuteScalarAsync<int>(sqlTotal, parametros);

                return (datos, total);
            }
        }
    }
}