using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SDV.UI.Services;
using System.Windows;

namespace SDV.UI.ViewModels
{
    public partial class MainViewModel : ObservableObject
    {
        // Solo cambia esta línea al inicio de la clase:
        [ObservableProperty] private object? _vistaActual; // Agrega el signo de interrogación '?'

        // Datos de usuario para mostrar en el menú
        [ObservableProperty] private string _nombreUsuario;
        [ObservableProperty] private string _rolUsuario;

        // --- VISIBILIDAD DE BOTONES (Por defecto COLAPSADOS/OCULTOS) ---
        [ObservableProperty] private Visibility _visibleAdmin = Visibility.Collapsed;
        [ObservableProperty] private Visibility _visibleRRHH = Visibility.Collapsed;
        [ObservableProperty] private Visibility _visibleVentas = Visibility.Collapsed;
        [ObservableProperty] private Visibility _visibleContabilidad = Visibility.Collapsed; // Agregado para ejemplo

        // Submenú
        [ObservableProperty] private bool _isSubmenuRRHHVisible;

        public MainViewModel()
        {
            // 1. Cargar datos básicos
            if (SesionActual.DatosEmpleado != null)
            {
                NombreUsuario = $"{SesionActual.DatosEmpleado.EmpNombre1} {SesionActual.DatosEmpleado.EmpApellido1}";
                RolUsuario = SesionActual.NombreRol;
            }
            else
            {
                NombreUsuario = "Invitado";
                RolUsuario = "Sin Rol";
            }

            // 2. APLICAR PERMISOS (El corazón de la seguridad)
            AplicarSeguridad();
        }

        private void AplicarSeguridad()
        {
            // TRUCO DE DIAGNÓSTICO:
            // Esto te dirá exactamente qué está viendo el sistema.
            // BORRA ESTE MESSAGEBOX CUANDO YA FUNCIONE.
            /*
            MessageBox.Show($"Rol Detectado ID: '{SesionActual.RolID}'\n" +
                            $"Es Admin: {SesionActual.EsAdmin}\n" +
                            $"Es RRHH: {SesionActual.EsRRHH}", 
                            "Depuración de Permisos");
            */

            // Lógica de Visibilidad
            if (SesionActual.EsAdmin)
            {
                // El admin ve TODO
                VisibleAdmin = Visibility.Visible;
                VisibleRRHH = Visibility.Visible;
                VisibleVentas = Visibility.Visible;
                VisibleContabilidad = Visibility.Visible;
            }
            else
            {
                // Si no es admin, activamos por partes

                // RRHH
                if (SesionActual.EsRRHH)
                    VisibleRRHH = Visibility.Visible;

                // Ventas
                if (SesionActual.EsVentas)
                    VisibleVentas = Visibility.Visible;

                // Contabilidad (Ejemplo si tuvieras lógica para eso)
                // if (SesionActual.EsConta) VisibleContabilidad = Visibility.Visible;
            }
        }
        [RelayCommand]
        public void NavegarNovedades()
        {
            // Cambia la vista actual al nuevo ViewModel de gestión
            VistaActual = new NovedadesViewModel();
        }
        // Dentro de MainViewModel.cs

        // Dentro de MainViewModel.cs

        [ObservableProperty] private bool _isSubmenuContabilidadVisible;

        [RelayCommand]
        public void ToggleSubmenuContabilidad()
        {
            IsSubmenuContabilidadVisible = !IsSubmenuContabilidadVisible;
            // Si abres contabilidad, cerramos RRHH para que no se amontonen
            if (IsSubmenuContabilidadVisible) IsSubmenuRRHHVisible = false;
        }

        [RelayCommand]
        public void NavegarPlanCuentas()
        {
            // Ahora usamos un ViewModel específico para el Plan de Cuentas
            VistaActual = new PlanCuentasViewModel();
        }

        [RelayCommand]
        public void NavegarLibroDiario()
        {
            // Ahora usamos un ViewModel específico para el Libro Diario
            VistaActual = new LibroDiarioViewModel();
        }

        // --- COMANDOS DE NAVEGACIÓN ---

        [RelayCommand]
        public void NavegarLogs()
        {
            // Doble chequeo de seguridad
            if (VisibleAdmin == Visibility.Visible)
                VistaActual = new LogsViewModel();
        }

        [RelayCommand]
        public void NavegarNomina()
        {
            if (VisibleRRHH == Visibility.Visible)
                VistaActual = new NominaViewModel();
        }

        [RelayCommand]
        public void IrAEmpleados()
        {
            if (VisibleRRHH == Visibility.Visible)
                VistaActual = new EmpleadoViewModel();
        }

        [RelayCommand]
        public void ToggleSubmenuRRHH()
        {
            if (VisibleRRHH == Visibility.Visible)
                IsSubmenuRRHHVisible = !IsSubmenuRRHHVisible;
        }
    }
}