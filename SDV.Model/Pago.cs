
using System;

namespace SDV.Model.Entities
{
    public class Pago
    {
        // Inicializamos con string.Empty para evitar el error de NULL
        public string IdPago { get; set; } = string.Empty;
        public string PagDescripcion { get; set; } = string.Empty;
        public DateTime PagFechaInicio { get; set; }
        public DateTime PagFechaFin { get; set; }
        public string EstadoPag { get; set; } = "ACT";
    }
}
