

namespace SDV.Model.Entities
{
    public class PagxEmp
    {
        public string IdPago { get; set; } = string.Empty;
        public int IdEmpleado { get; set; }
        public decimal EmpSueldo { get; set; }
        public decimal EmpBonificaciones { get; set; }
        public decimal EmpDescuentos { get; set; }
        public decimal EmpValorNeto { get; set; }
        public string EstadoPxE { get; set; } = "ACT";

        public string NombreEmpleado { get; set; } = string.Empty; // Inicializado
    }
}