using System;

namespace SDV.Model.Entities
{
    public class DesxEmpxPag
    {
        public string IdDescuento { get; set; } = string.Empty;
        public int IdEmpleado { get; set; }
        public string IdPago { get; set; } = string.Empty;
        public DateTime DxeFecha { get; set; } = DateTime.Now;
        public decimal DxeValor { get; set; }
        public string EstadoDxe { get; set; } = "ACT";

        // Propiedad auxiliar para mostrar en la lista
        public string Descripcion { get; set; } = string.Empty;
    }
}