using System;

namespace SDV.Model.Entities
{
    public class BonxEmpxPag
    {
        public string IdBonificacion { get; set; } = string.Empty;
        public int IdEmpleado { get; set; }
        public string IdPago { get; set; } = string.Empty;
        public DateTime BxeFecha { get; set; } = DateTime.Now;
        public decimal BxeValor { get; set; }
        public string EstadoBxe { get; set; } = "ACT";

        // Propiedad auxiliar para mostrar en la lista (no va a la BD)
        public string Descripcion { get; set; } = string.Empty;
    }
}