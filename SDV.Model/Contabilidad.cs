using System;

namespace SDV.Model.Entities
{
    public class CuentaContable
    {
        public string IdCodigoCuenta { get; set; } = string.Empty;
        public string CueNombreCuenta { get; set; } = string.Empty;
        public string CueTipoCuenta { get; set; } = string.Empty; // MAY o DET
        public string CueEstadoCuenta { get; set; } = string.Empty;
    }

    public class AsientoContable
    {
        public string IdAsientoContable { get; set; } = string.Empty;
        public DateTime AsiFechaHora { get; set; }
        public string AsiDescripcion { get; set; } = string.Empty;
        public decimal AsiTotalDebe { get; set; }
        public decimal AsiTotalHaber { get; set; }
    }

    public class CuentaXAsiento
    {
        public string IdCodigoCuenta { get; set; } = string.Empty;
        public decimal CxaMontoDebe { get; set; }
        public decimal CxaMontoHaber { get; set; }
        public string CxaDescripcion { get; set; } = string.Empty;
    }
}