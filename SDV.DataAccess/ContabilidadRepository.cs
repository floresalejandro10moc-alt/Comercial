using Dapper;
using SDV.Model.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SDV.DataAccess.Repositories
{
    public class ContabilidadRepository : RepositoryBase
    {
        public async Task<IEnumerable<CuentaContable>> GetPlanCuentasAsync(string filtro = "")
        {
            using (var db = GetConnection())
            {
                // Tabla: 'cuentas' en minúsculas. Atributos intactos.
                string sql = @"SELECT ID_CODIGOCUENTA as IdCodigoCuenta, 
                               CUE_NOMBRECUENTA as CueNombreCuenta, 
                               CUE_TIPOCUENTA as CueTipoCuenta, 
                               CUE_ESTADOCUENTA as CueEstadoCuenta 
                               FROM cuentas 
                               WHERE CUE_NOMBRECUENTA LIKE @f OR ID_CODIGOCUENTA LIKE @f";

                return await db.QueryAsync<CuentaContable>(sql, new { f = $"%{filtro}%" });
            }
        }

        public async Task<IEnumerable<AsientoContable>> GetAsientosHeadersAsync(string filtro = "")
        {
            using (var db = GetConnection())
            {
                // Tabla: 'asientos' en minúsculas. Atributos intactos.
                string sql = @"SELECT ID_ASIENTOCONTABLE as IdAsientoContable, 
                               ASI_FECHAHORA as AsiFechaHora, 
                               ASI_DESCRIPCION as AsiDescripcion, 
                               ASI_TOTAL_DEBE as AsiTotalDebe,
                               ASI_TOTAL_HABER as AsiTotalHaber
                               FROM asientos
                               WHERE ASI_DESCRIPCION LIKE @f OR ID_ASIENTOCONTABLE LIKE @f
                               ORDER BY ASI_FECHAHORA DESC";

                return await db.QueryAsync<AsientoContable>(sql, new { f = $"%{filtro}%" });
            }
        }

        public async Task<IEnumerable<CuentaXAsiento>> GetDetallesAsientoAsync(string idAsiento)
        {
            using (var db = GetConnection())
            {
                // Tabla: 'cuentasxasiento' en minúsculas. Atributos intactos.
                string sql = @"SELECT ID_CODIGOCUENTA as IdCodigoCuenta, 
                               CXA_MONTODEBE as CxaMontoDebe, 
                               CXA_MONTOHABER as CxaMontoHaber, 
                               CXA_DESCRIPCION as CxaDescripcion 
                               FROM cuentasxasiento WHERE ID_ASIENTOCONTABLE = @id";

                return await db.QueryAsync<CuentaXAsiento>(sql, new { id = idAsiento });
            }
        }
    }
}