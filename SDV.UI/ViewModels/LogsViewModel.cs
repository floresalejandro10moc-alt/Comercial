using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SDV.DataAccess.Repositories;
using SDV.Model.Entities;
using SDV.UI.Services;
using System;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using System.Windows;

namespace SDV.UI.ViewModels
{
    public partial class LogsViewModel : ObservableObject
    {
        private readonly LogRepository _logRepo = new LogRepository();
        private const int REGISTROS_POR_PAGINA = 50; // Requisito: 50 en 50

        // --- DATOS ---
        [ObservableProperty] private ObservableCollection<AuditLog> _listaLogs = new();

        // --- FILTROS Y PAGINACIÓN ---
        [ObservableProperty] private DateTime? _fechaSeleccionada = null; // Null = Ver todo
        [ObservableProperty] private int _paginaActual = 1;
        [ObservableProperty] private int _totalRegistros = 0;
        [ObservableProperty] private int _totalPaginas = 0;
        [ObservableProperty] private string _textoPaginacion = "Cargando...";

        public LogsViewModel()
        {
            // Iniciar cargando todo (sin fecha, página 1)
            Task.Run(async () => await CargarLogs());
        }

        // Se ejecuta cuando el usuario cambia la fecha en el DatePicker
        partial void OnFechaSeleccionadaChanged(DateTime? value)
        {
            PaginaActual = 1; // Reiniciar a página 1 si cambiamos filtro
            Task.Run(async () => await CargarLogs());
        }

        [RelayCommand]
        public async Task CargarLogs()
        {
            try
            {
                var (logs, total) = await _logRepo.ObtenerLogsPaginadosAsync(PaginaActual, REGISTROS_POR_PAGINA, FechaSeleccionada);

                Application.Current.Dispatcher.Invoke(() =>
                {
                    ListaLogs = new ObservableCollection<AuditLog>(logs);
                    TotalRegistros = total;

                    // Calcular total páginas (Matemática simple: Total / 50)
                    TotalPaginas = (int)Math.Ceiling((double)TotalRegistros / REGISTROS_POR_PAGINA);
                    if (TotalPaginas == 0) TotalPaginas = 1;

                    TextoPaginacion = $"Página {PaginaActual} de {TotalPaginas} (Total: {TotalRegistros} registros)";
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error logs: {ex.Message}");
            }
        }

        // --- COMANDOS DE PAGINACIÓN ---

        [RelayCommand]
        public async Task SiguientePagina()
        {
            if (PaginaActual < TotalPaginas)
            {
                PaginaActual++;
                await CargarLogs();
            }
        }

        [RelayCommand]
        public async Task AnteriorPagina()
        {
            if (PaginaActual > 1)
            {
                PaginaActual--;
                await CargarLogs();
            }
        }

        [RelayCommand]
        public void LimpiarFiltro()
        {
            FechaSeleccionada = null; // Esto dispara OnFechaSeleccionadaChanged automáticamente
        }
    }
}