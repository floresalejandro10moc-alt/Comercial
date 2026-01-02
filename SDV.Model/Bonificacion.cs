namespace SDV.Model.Entities
{
    public class Bonificacion
    {
        public string Id { get; set; } = string.Empty;          // Inicializado
        public string Descripcion { get; set; } = string.Empty; // Inicializado
        public decimal Valor { get; set; }
    }
}