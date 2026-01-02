using Dapper;
using SDV.Model.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SDV.DataAccess.Repositories
{
    public class LogRepository : RepositoryBase
    {
        // Método que devuelve: (Lista de Logs, Total de Registros para calcular páginas)
        public async Task<(IEnumerable<AuditLog>, int)> ObtenerLogsPaginadosAsync(int pagina, int registrosPorPagina, DateTime? fechaFiltro)
        {
            using (var db = GetConnection())
            {
                // 1. Construir el filtro de fecha dinámicamente
                // Si fechaFiltro es null, no filtramos. Si tiene fecha, filtramos por ese día.
                string condicionFecha = fechaFiltro.HasValue ? "WHERE DATE(fecha_hora) = DATE(@Fecha)" : "";

                // 2. Calcular desde dónde empezar (Offset)
                int saltar = (pagina - 1) * registrosPorPagina;

                // 3. SQL para traer los datos (Paginados)
                // OJO: Mapeo explícito para arreglar el problema del ID y el Detalle
                var sqlDatos = $@"
                    SELECT 
                        id_log           AS IdLog,
                        fecha_hora       AS FechaHora,
                        usuario_sistema  AS Usuario,
                        tabla_afectada   AS Tabla,
                        accion           AS Accion,
                        -- Priorizamos mostrar el detalle, si es nulo, mostramos datos nuevos o vacio
                        COALESCE(accion_detallada, datos_nuevos, datos_anteriores, '') AS Detalle,
                        nivel            AS Nivel
                    FROM auditoria_log
                    {condicionFecha}
                    ORDER BY id_log DESC
                    LIMIT @Limit OFFSET @Offset";

                // 4. SQL para contar el total (para saber cuántas páginas hay)
                var sqlTotal = $"SELECT COUNT(*) FROM auditoria_log {condicionFecha}";

                // 5. Ejecutar consultas
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