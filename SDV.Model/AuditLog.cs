using System;

namespace SDV.Model.Entities
{
    public class AuditLog
    {
        public long IdLog { get; set; }
        public DateTime FechaHora { get; set; }

        // Inicializamos para evitar error de Nulos
        public string Usuario { get; set; } = string.Empty;
        public string Tabla { get; set; } = string.Empty;
        public string Accion { get; set; } = string.Empty;
        public string Detalle { get; set; } = string.Empty;
        public string Nivel { get; set; } = string.Empty;
    }
}