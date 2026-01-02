using System;

namespace SDV.Model.Entities
{
    public class Empleado
    {
        // PK
        public int IdEmpleado { get; set; }

        // Identificación
        public string EmpCedula { get; set; } = string.Empty;

        // Nombres Completos (Separados como en tu BD)
        public string EmpApellido1 { get; set; } = string.Empty;
        public string EmpApellido2 { get; set; } = string.Empty;
        public string EmpNombre1 { get; set; } = string.Empty;
        public string EmpNombre2 { get; set; } = string.Empty;

        // Datos Demográficos
        public string EmpSexo { get; set; } = "M"; // 'M' o 'F'
        public DateTime EmpFechaNacimiento { get; set; } = DateTime.Now.AddYears(-18);

        public string EmpCargo { get; set; } = "No asignado";
        // Datos Laborales
        public decimal EmpSueldo { get; set; }
        public string EmpMail { get; set; } = string.Empty;
        public string EstadoEmp { get; set; } = "ACT"; // Por defecto ACT

        // Relaciones (Foreign Keys)
        public string IdDepartamento { get; set; } = string.Empty;
        public string IdRol { get; set; } = string.Empty;

        // Propiedades de Solo Lectura para la Tabla (Vistas)
        public string NombreCompleto => $"{EmpApellido1} {EmpApellido2} {EmpNombre1} {EmpNombre2}";
        public string NombreDepartamento { get; set; } = string.Empty; // Se llena con JOIN
        public string NombreCargo { get; set; } = string.Empty;        // Se llena con JOIN
    }
}