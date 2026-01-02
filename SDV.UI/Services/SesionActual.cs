using SDV.Model.Entities;

namespace SDV.UI.Services
{
    public static class SesionActual
    {
        public static Empleado? DatosEmpleado { get; private set; }
        public static string RolID { get; private set; } = string.Empty;
        public static string NombreRol { get; private set; } = string.Empty;

        public static void Iniciar(Empleado empleado, string idRol, string nombreRol)
        {
            DatosEmpleado = empleado;
            // .Trim() elimina espacios en blanco que causan fallos (Ej: "ROL-ADM " vs "ROL-ADM")
            RolID = (idRol ?? "").Trim().ToUpper();
            NombreRol = (nombreRol ?? "").Trim();
        }

        public static void Cerrar()
        {
            DatosEmpleado = null;
            RolID = string.Empty;
            NombreRol = string.Empty;
        }

        // --- PERMISOS (Ajustados a tus INSERTS SQL) ---

        // Admin General o Gerente de Sistemas
        public static bool EsAdmin =>
            RolID == "ROL-ADM" || RolID == "S-CEO" || RolID == "S-GER" || RolID == "S-DBA";

        // Talento Humano (Cualquiera que empiece con T- o ROL-RH)
        public static bool EsRRHH =>
            RolID == "ROL-RH" || RolID.StartsWith("T-") || EsAdmin;

        // Ventas
        public static bool EsVentas =>
            RolID == "ROL-VEN" || RolID.StartsWith("V-") || EsAdmin;

        // Contabilidad
        public static bool EsContabilidad =>
            RolID == "ROL-CON" || RolID.StartsWith("CG-") || EsAdmin;
    }
}