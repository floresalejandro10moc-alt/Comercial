using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SDV.DataAccess.Repositories;
using SDV.Model.Entities;
using SDV.UI.Services;
using SDV.UI.Views;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Media;

namespace SDV.UI.ViewModels
{
    public partial class NominaViewModel : ObservableObject
    {
        private readonly EmpleadoRepository _empRepo = new EmpleadoRepository();
        private readonly NominaRepository _nominaRepo = new NominaRepository();
        private readonly IMessageDialogService _dialogService;

        // --- NAVEGACIÓN Y ESTADO ---
        [ObservableProperty] private int _tabSeleccionadoIndex = 0;
        [ObservableProperty] private bool _isModoCreacion = true;

        // --- DATOS HISTORIAL ---
        private ObservableCollection<PagxEmp> _listaRolesHistorialRaw = new();
        [ObservableProperty] private ICollectionView _listaRolesHistorial;
        [ObservableProperty] private string _filtroBusqueda = string.Empty;

        // --- DATOS GESTIÓN ---
        private ObservableCollection<Empleado> _listaEmpleadosRaw = new();
        private ObservableCollection<Bonificacion> _listaBonosRaw = new();
        private ObservableCollection<Descuento> _listaDescuentosRaw = new();

        [ObservableProperty] private ICollectionView _listaEmpleadosView;
        [ObservableProperty] private ICollectionView _listaBonosView;
        [ObservableProperty] private ICollectionView _listaDescuentosView;

        // Filtros
        [ObservableProperty] private string _filtroEmpleado = string.Empty;
        [ObservableProperty] private string _filtroBono = string.Empty;
        [ObservableProperty] private string _filtroDescuento = string.Empty;

        // --- SELECCIONES ---
        [ObservableProperty] private Empleado? _empleadoSeleccionado;
        [ObservableProperty] private Bonificacion? _bonoSeleccionado;
        [ObservableProperty] private Descuento? _descuentoSeleccionado;

        // --- INPUTS MANUALES ---
        [ObservableProperty] private string _valorBonoInput = "0";
        [ObservableProperty] private string _valorDescuentoInput = "0";

        // --- OBJETOS PRINCIPALES ---
        [ObservableProperty] private Pago _pagoActual = new();
        [ObservableProperty] private PagxEmp _rolDetalle = new();
        [ObservableProperty] private string _asientoTexto = string.Empty;

        // --- LISTAS OBSERVABLES (CORREGIDO: Propiedades generadas) ---
        [ObservableProperty] private ObservableCollection<BonxEmpxPag> _bonosAplicados = new();
        [ObservableProperty] private ObservableCollection<DesxEmpxPag> _descuentosAplicados = new();
        //Resumen 
        [ObservableProperty] private decimal _totalGastoNomina;
        [ObservableProperty] private int _cantidadRolesPendientes;
        [ObservableProperty] private int _cantidadRolesAprobados;
        //NAvegar
        [ObservableProperty] private int _paginaActual = 1;
        [ObservableProperty] private int _totalPaginas = 1;
        private const int RegistrosPorPagina = 15;
        //Grafico
        [ObservableProperty] private decimal _totalEnero;
        [ObservableProperty] private decimal _totalFebrero;
        [ObservableProperty] private decimal _totalMarzo;
        // ... puedes hacer esto más dinámico con una colección, pero esto es lo más rápido


        // =========================================================
        // CONSTRUCTOR
        // =========================================================
        public NominaViewModel()
        {
            _dialogService = new MessageDialogService();
            InicializarCabecera();

            // 1. INICIALIZAR VISTAS
            _listaRolesHistorial = CollectionViewSource.GetDefaultView(_listaRolesHistorialRaw);
            _listaEmpleadosView = CollectionViewSource.GetDefaultView(_listaEmpleadosRaw);
            _listaBonosView = CollectionViewSource.GetDefaultView(_listaBonosRaw);
            _listaDescuentosView = CollectionViewSource.GetDefaultView(_listaDescuentosRaw);

            // 2. CONFIGURAR FILTROS
            _listaRolesHistorial.Filter = FiltroHistorialLogica;
            _listaEmpleadosView.Filter = FiltroEmpleadosLogica;
            _listaBonosView.Filter = FiltroBonosLogica;
            _listaDescuentosView.Filter = FiltroDescuentosLogica;

            // 3. CARGAR DATOS
            Task.Run(async () => await CargarDatosIniciales());
        }
        // Propiedad para la lista que realmente ve la UI (Paginada)
        private ObservableCollection<PagxEmp> _listaRolesPaginada = new();
        public ObservableCollection<PagxEmp> ListaRolesPaginada
        {
            get => _listaRolesPaginada;
            set => SetProperty(ref _listaRolesPaginada, value);
        }

        // --- Actualiza el método RefrescarHistorial ---
        [RelayCommand]
        public async Task RefrescarHistorial()
        {
            try
            {
                var historial = await _nominaRepo.GetHistorialRolesAsync();
                var listaCompleta = historial.ToList();

                Application.Current.Dispatcher.Invoke(() => {
                    _listaRolesHistorialRaw.Clear();
                    foreach (var item in listaCompleta) _listaRolesHistorialRaw.Add(item);

                    // Dashboard
                    TotalGastoNomina = listaCompleta.Sum(x => x.EmpValorNeto);
                    CantidadRolesPendientes = listaCompleta.Count(x => x.EstadoPxE == "PEN");
                    CantidadRolesAprobados = listaCompleta.Count(x => x.EstadoPxE == "APR");

                    PaginaActual = 1;
                    CalcularPaginacion();
                });
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine(ex.Message); }
        }

        private void CalcularPaginacion()
        {
            // Filtrar primero según la búsqueda
            var filtrados = _listaRolesHistorialRaw.Where(x =>
                string.IsNullOrEmpty(FiltroBusqueda) ||
                x.NombreEmpleado.IndexOf(FiltroBusqueda, StringComparison.OrdinalIgnoreCase) >= 0 ||
                x.IdPago.Contains(FiltroBusqueda)).ToList();

            TotalPaginas = (int)Math.Ceiling(filtrados.Count / (double)RegistrosPorPagina);
            if (TotalPaginas == 0) TotalPaginas = 1;

            var pagedData = filtrados.Skip((PaginaActual - 1) * RegistrosPorPagina).Take(RegistrosPorPagina);

            ListaRolesPaginada.Clear();
            foreach (var item in pagedData) ListaRolesPaginada.Add(item);
        }

        [RelayCommand]
        public void SiguientePagina() { if (PaginaActual < TotalPaginas) { PaginaActual++; CalcularPaginacion(); } }

        [RelayCommand]
        public void AnteriorPagina() { if (PaginaActual > 1) { PaginaActual--; CalcularPaginacion(); } }

        // Asegurar que al buscar se resetee la página
        partial void OnFiltroBusquedaChanged(string value) { PaginaActual = 1; CalcularPaginacion(); }

        private void InicializarCabecera()
        {
            string idGenerado = DateTime.Now.ToString("yyyy-MM");
            PagoActual = new Pago
            {
                IdPago = idGenerado,
                PagDescripcion = $"Rol {DateTime.Now:MMMM yyyy}",
                PagFechaInicio = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1),
                PagFechaFin = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).AddMonths(1).AddDays(-1)
            };
        }

        private async Task CargarDatosIniciales()
        {
            try
            {
                var emps = await _empRepo.GetAllAsync();
                var bonos = await _nominaRepo.GetBonificacionesAsync();
                var descs = await _nominaRepo.GetDescuentosAsync();
                var historial = await _nominaRepo.GetHistorialRolesAsync();

                Application.Current.Dispatcher.Invoke(() =>
                {
                    _listaEmpleadosRaw.Clear(); foreach (var e in emps) _listaEmpleadosRaw.Add(e);
                    _listaBonosRaw.Clear(); foreach (var b in bonos) _listaBonosRaw.Add(b);
                    _listaDescuentosRaw.Clear(); foreach (var d in descs) _listaDescuentosRaw.Add(d);
                    _listaRolesHistorialRaw.Clear(); foreach (var h in historial) _listaRolesHistorialRaw.Add(h);

                    ListaRolesHistorial.Refresh();
                    ListaEmpleadosView.Refresh();
                });
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}"); }
        }

        // --- FILTROS ---
        private bool FiltroHistorialLogica(object item)
        {
            if (string.IsNullOrEmpty(FiltroBusqueda)) return true;
            var rol = item as PagxEmp;
            return (rol.NombreEmpleado != null && rol.NombreEmpleado.IndexOf(FiltroBusqueda, StringComparison.OrdinalIgnoreCase) >= 0) ||
                   (rol.IdPago != null && rol.IdPago.Contains(FiltroBusqueda));
        }
        private bool FiltroEmpleadosLogica(object item) => string.IsNullOrEmpty(FiltroEmpleado) || ((Empleado)item).NombreCompleto.IndexOf(FiltroEmpleado, StringComparison.OrdinalIgnoreCase) >= 0;
        private bool FiltroBonosLogica(object item) => string.IsNullOrEmpty(FiltroBono) || ((Bonificacion)item).Descripcion.IndexOf(FiltroBono, StringComparison.OrdinalIgnoreCase) >= 0;
        private bool FiltroDescuentosLogica(object item) => string.IsNullOrEmpty(FiltroDescuento) || ((Descuento)item).Descripcion.IndexOf(FiltroDescuento, StringComparison.OrdinalIgnoreCase) >= 0;

        partial void OnFiltroEmpleadoChanged(string value) => ListaEmpleadosView.Refresh();
        partial void OnFiltroBonoChanged(string value) => ListaBonosView.Refresh();
        partial void OnFiltroDescuentoChanged(string value) => ListaDescuentosView.Refresh();

        // --- AUTOCOMPLETADO ---
        partial void OnBonoSeleccionadoChanged(Bonificacion? value) { if (value != null) ValorBonoInput = value.Valor.ToString("F2"); }
        partial void OnDescuentoSeleccionadoChanged(Descuento? value) { if (value != null) ValorDescuentoInput = value.Valor.ToString("F2"); }

        // --- CRUD Y NAVEGACIÓN ---

        [RelayCommand]
        public void IrACrearNuevo()
        {
            LimpiarFormulario();

            // IMPORTANTE: Debes llamar a este método AQUÍ para que 
            // PagoActual.IdPago vuelva a ser el del mes/año actual (2025-12).
            InicializarCabecera();

            IsModoCreacion = true;
            TabSeleccionadoIndex = 1;
        }

        [RelayCommand]
        public void Regresar()
        {
            LimpiarFormulario();
            TabSeleccionadoIndex = 0;
        }

        [RelayCommand]
        public async Task CargarParaEditar(PagxEmp rolSeleccionado)
        {
            if (rolSeleccionado == null) return;

            if (rolSeleccionado.EstadoPxE == "APR")
            {
                _dialogService.ShowMessage("Acceso Denegado", "Este rol de pago fue APROBADO. Ya no se puede editar.");
                return;
            }
            if (rolSeleccionado.EstadoPxE == "ANU")
            {
                _dialogService.ShowMessage("Acceso Denegado", "Este rol está ANULADO.");
                return;
            }

            try
            {
                LimpiarFormulario();
                IsModoCreacion = false;
                PagoActual = new Pago
                {
                    IdPago = rolSeleccionado.IdPago,
                    PagDescripcion = $"Rol {rolSeleccionado.IdPago}"
                };

                RolDetalle = rolSeleccionado;

                var emp = _listaEmpleadosRaw.FirstOrDefault(e => e.IdEmpleado == rolSeleccionado.IdEmpleado);
                if (emp != null) EmpleadoSeleccionado = emp;

                var bonosDB = await _nominaRepo.GetDetallesBonosAsync(rolSeleccionado.IdPago, rolSeleccionado.IdEmpleado);
                var descsDB = await _nominaRepo.GetDetallesDescuentosAsync(rolSeleccionado.IdPago, rolSeleccionado.IdEmpleado);

                BonosAplicados = new ObservableCollection<BonxEmpxPag>(bonosDB);
                DescuentosAplicados = new ObservableCollection<DesxEmpxPag>(descsDB);

                RecalcularTodo();
                TabSeleccionadoIndex = 1;
            }
            catch (Exception ex) { _dialogService.ShowMessage("Error al cargar", ex.Message); }
        }

        [RelayCommand]
        public async Task EliminarDeLista(PagxEmp rol)
        {
            var confirm = MessageBox.Show($"¿Desea ANULAR el rol de {rol.NombreEmpleado}?", "Confirmar Anulación", MessageBoxButton.YesNo, MessageBoxImage.Warning);
            if (confirm == MessageBoxResult.Yes)
            {
                await _nominaRepo.AnularRolAsync(rol.IdPago, rol.IdEmpleado);
                await RefrescarHistorial();
            }
        }

        [RelayCommand]
        public async Task AnularDesdeGestion()
        {
            if (RolDetalle == null || RolDetalle.IdEmpleado == 0) return;
            await EliminarDeLista(RolDetalle);
            LimpiarFormulario();
            TabSeleccionadoIndex = 0;
        }

        [RelayCommand]
        public void EliminarBonoDetalle(BonxEmpxPag item)
        {
            if (item != null)
            {
                BonosAplicados.Remove(item);
                RecalcularTodo();
            }
        }

        [RelayCommand]
        public void EliminarDescuentoDetalle(DesxEmpxPag item)
        {
            if (item != null)
            {
                DescuentosAplicados.Remove(item);
                RecalcularTodo();
            }
        }

        // --- CÁLCULO ---
        partial void OnEmpleadoSeleccionadoChanged(Empleado? value)
        {
            if (value != null && IsModoCreacion)
            {
                // Validar si ya tiene un rol en este mes
                Task.Run(async () =>
                {
                    bool existe = await _nominaRepo.ExisteRolAsync(PagoActual.IdPago, value.IdEmpleado);
                    if (existe)
                    {
                        Application.Current.Dispatcher.Invoke(() => {
                            _dialogService.ShowMessage("Atención", $"El empleado {value.NombreCompleto} ya tiene un rol generado para el periodo {PagoActual.IdPago}.");
                            EmpleadoSeleccionado = null; // Resetear selección
                        });
                    }
                    else
                    {
                        // Lógica normal de carga si no existe
                        Application.Current.Dispatcher.Invoke(() => {
                            BonosAplicados.Clear(); DescuentosAplicados.Clear();
                            RolDetalle = new PagxEmp
                            {
                                IdPago = PagoActual.IdPago,
                                IdEmpleado = value.IdEmpleado,
                                NombreEmpleado = value.NombreCompleto,
                                EmpSueldo = value.EmpSueldo,
                                EstadoPxE = "PEN"
                            };
                            RecalcularTodo();
                        });
                    }
                });
            }
        }

        [RelayCommand]
        public void AgregarBono()
        {
            string inputNormalizado = ValorBonoInput.Replace(",", ".");
            if (BonoSeleccionado == null || !decimal.TryParse(inputNormalizado, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal valor) || valor <= 0) return;

            // CORREGIDO: Usamos la propiedad BonosAplicados
            BonosAplicados.Add(new BonxEmpxPag
            {
                IdBonificacion = BonoSeleccionado.Id,
                IdEmpleado = EmpleadoSeleccionado?.IdEmpleado ?? 0,
                IdPago = PagoActual.IdPago,
                BxeValor = valor,
                Descripcion = BonoSeleccionado.Descripcion,
                BxeFecha = DateTime.Now  // Asegúrate de asignar la fecha aquí
            });
            RecalcularTodo();
        }
        [RelayCommand]
        public void ExportarHistorialExcel()
        {
            try
            {
                var saveFileDialog = new Microsoft.Win32.SaveFileDialog
                {
                    Filter = "Excel Files|*.xlsx",
                    FileName = $"Reporte_Nomina_{DateTime.Now:yyyyMMdd}"
                };

                if (saveFileDialog.ShowDialog() == true)
                {
                    using (var workbook = new ClosedXML.Excel.XLWorkbook())
                    {
                        var worksheet = workbook.Worksheets.Add("Historial de Roles");

                        // Encabezados
                        worksheet.Cell(1, 1).Value = "ID Pago";
                        worksheet.Cell(1, 2).Value = "Empleado";
                        worksheet.Cell(1, 3).Value = "Sueldo Base";
                        worksheet.Cell(1, 4).Value = "Bonos";
                        worksheet.Cell(1, 5).Value = "Descuentos";
                        worksheet.Cell(1, 6).Value = "Neto a Recibir";
                        worksheet.Cell(1, 7).Value = "Estado";

                        // Datos
                        int fila = 2;
                        foreach (var rol in ListaRolesHistorial)
                        {
                            var r = (PagxEmp)rol;
                            worksheet.Cell(fila, 1).Value = r.IdPago;
                            worksheet.Cell(fila, 2).Value = r.NombreEmpleado;
                            worksheet.Cell(fila, 3).Value = r.EmpSueldo;
                            worksheet.Cell(fila, 4).Value = r.EmpBonificaciones;
                            worksheet.Cell(fila, 5).Value = r.EmpDescuentos;
                            worksheet.Cell(fila, 6).Value = r.EmpValorNeto;
                            worksheet.Cell(fila, 7).Value = r.EstadoPxE;
                            fila++;
                        }

                        worksheet.Columns().AdjustToContents(); // Ajustar ancho
                        workbook.SaveAs(saveFileDialog.FileName);
                        _dialogService.ShowMessage("Éxito", "Archivo Excel generado correctamente.");
                    }
                }
            }
            catch (Exception ex) { _dialogService.ShowMessage("Error", ex.Message); }
        }

        [RelayCommand]
        public void AgregarDescuento()
        {
            string inputNormalizado = ValorDescuentoInput.Replace(",", ".");
            if (DescuentoSeleccionado == null || !decimal.TryParse(inputNormalizado, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal valor) || valor <= 0) return;

            // CORREGIDO: Usamos la propiedad DescuentosAplicados
            DescuentosAplicados.Add(new DesxEmpxPag
            {
                IdDescuento = DescuentoSeleccionado.Id,
                IdEmpleado = EmpleadoSeleccionado?.IdEmpleado ?? 0,
                IdPago = PagoActual.IdPago,
                DxeValor = valor,
                Descripcion = DescuentoSeleccionado.Descripcion
            });
            RecalcularTodo();
        }

        private void RecalcularTodo()
        {
            if (RolDetalle == null) return;
            decimal iess = Math.Round(RolDetalle.EmpSueldo * 0.0945m, 2);
            RolDetalle.EmpBonificaciones = BonosAplicados.Sum(x => x.BxeValor);
            RolDetalle.EmpDescuentos = iess + DescuentosAplicados.Sum(x => x.DxeValor);
            RolDetalle.EmpValorNeto = (RolDetalle.EmpSueldo + RolDetalle.EmpBonificaciones) - RolDetalle.EmpDescuentos;
            GenerarAsientoVisual(iess);
            OnPropertyChanged(nameof(RolDetalle));
        }
        [RelayCommand]
        public async Task ImprimirRol(PagxEmp rolSeleccionado)
        {
            if (rolSeleccionado == null) return;

            try
            {
                // Buscamos empleado y detalles
                var empCompleto = _listaEmpleadosRaw.FirstOrDefault(e => e.IdEmpleado == rolSeleccionado.IdEmpleado);
                var bonos = await _nominaRepo.GetDetallesBonosAsync(rolSeleccionado.IdPago, rolSeleccionado.IdEmpleado);
                var descs = await _nominaRepo.GetDetallesDescuentosAsync(rolSeleccionado.IdPago, rolSeleccionado.IdEmpleado);

                // BUSQUEDA DE CABECERA CON MANEJO DE NULOS
                var cabeceraDB = await _nominaRepo.GetPagoByIdAsync(rolSeleccionado.IdPago);

                // Si cabeceraDB es null, creamos un objeto con datos mínimos para que no falle el servicio
                Pago cabeceraSegura = cabeceraDB ?? new Pago
                {
                    IdPago = rolSeleccionado.IdPago,
                    PagDescripcion = "Rol del Periodo " + rolSeleccionado.IdPago,
                    PagFechaInicio = DateTime.Now
                };

                PrintService printService = new PrintService();

                // Enviamos los datos asegurando que cedula y cargo tengan texto
                printService.ImprimirRolIndividual(
                    cabeceraSegura,
                    rolSeleccionado,
                    bonos,
                    descs,
                    empCompleto?.EmpCedula ?? "S/N",
                    empCompleto?.EmpCargo ?? "Personal"
                );
            }
            catch (Exception ex)
            {
                _dialogService.ShowMessage("Error", "No se pudo preparar la impresión: " + ex.Message);
            }
        }
        [RelayCommand]
        public void GenerarArchivoBanco()
        {
            // 1. Filtramos solo los aprobados del mes actual
            var aprobados = _listaRolesHistorialRaw
                .Where(x => x.IdPago == PagoActual.IdPago && x.EstadoPxE == "APR")
                .ToList();

            if (!aprobados.Any())
            {
                _dialogService.ShowMessage("Aviso", "No hay roles APROBADOS en este periodo para generar el archivo.");
                return;
            }

            // 2. Diálogo para guardar el archivo
            var saveFileDialog = new Microsoft.Win32.SaveFileDialog
            {
                Filter = "Archivo CSV (*.csv)|*.csv",
                FileName = $"PAGOS_BANCO_{PagoActual.IdPago}"
            };

            if (saveFileDialog.ShowDialog() == true)
            {
                try
                {
                    using (var writer = new System.IO.StreamWriter(saveFileDialog.FileName, false, System.Text.Encoding.UTF8))
                    {
                        // Encabezado del archivo
                        writer.WriteLine("CEDULA;NOMBRE_EMPLEADO;VALOR_NETO");

                        foreach (var rol in aprobados)
                        {
                            // Buscamos la cédula en la lista de empleados
                            var emp = _listaEmpleadosRaw.FirstOrDefault(e => e.IdEmpleado == rol.IdEmpleado);
                            writer.WriteLine($"{emp?.EmpCedula ?? "0000000000"};{rol.NombreEmpleado};{rol.EmpValorNeto.ToString("F2")}");
                        }
                    }
                    _dialogService.ShowMessage("Éxito", "Archivo de transferencia generado correctamente.");
                }
                catch (Exception ex) { _dialogService.ShowMessage("Error", ex.Message); }
            }
        }
        [RelayCommand]
        public void ImprimirReporteMensual()
        {
            if (_listaRolesHistorialRaw.Count == 0) return;

            PrintService service = new PrintService();
            // Filtramos los que pertenecen al periodo actual generado
            var rolesDelMes = _listaRolesHistorialRaw.Where(x => x.IdPago == PagoActual.IdPago).ToList();

            if (rolesDelMes.Count > 0)
                service.ImprimirResumenMensual(PagoActual.IdPago, rolesDelMes);
            else
                _dialogService.ShowMessage("Aviso", "No hay roles guardados para el periodo seleccionado.");
        }

        // --- GUARDADO ---
        [RelayCommand]
        public async Task GuardarRol() => await ProcesarGuardado("PEN");

        [RelayCommand]
        public async Task GuardarYFirmar() => await ProcesarGuardado("APR");

        private async Task ProcesarGuardado(string estado)
        {
            if (EmpleadoSeleccionado == null) { _dialogService.ShowMessage("Error", "Seleccione empleado."); return; }
            try
            {
                RolDetalle.EstadoPxE = estado;
                RolDetalle.IdPago = PagoActual.IdPago;

                // CORREGIDO: Convertimos ObservableCollection a List con .ToList()
                await _nominaRepo.GuardarNominaCompletaAsync(
                    PagoActual,
                    RolDetalle,
                    BonosAplicados.ToList(),
                    DescuentosAplicados.ToList(),
                    AsientoTexto
                );

                string msj = estado == "APR" ? "Rol Aprobado y Firmado." : "Borrador Guardado (Pendiente).";
                _dialogService.ShowMessage("Éxito", msj);

                await RefrescarHistorial();
                TabSeleccionadoIndex = 0;
            }
            catch (Exception ex) { _dialogService.ShowMessage("Error", ex.Message); }
        }


        private void LimpiarFormulario()
        {
            // Reseteamos el detalle del empleado
            RolDetalle = new PagxEmp();
            EmpleadoSeleccionado = null;
            BonosAplicados.Clear();
            DescuentosAplicados.Clear();
            AsientoTexto = string.Empty;
            ValorBonoInput = "0";
            ValorDescuentoInput = "0";

            // Nota: No llamamos a InicializarCabecera aquí dentro si quieres 
            // que la limpieza sea "neutral", pero es obligatorio llamarlo en IrACrearNuevo.
        }

        private void GenerarAsientoVisual(decimal iess)
        {
            var sb = new StringBuilder();
            sb.AppendLine("==================================================");
            sb.AppendLine("            VISTA PREVIA LIBRO DIARIO");
            sb.AppendLine("==================================================");
            sb.AppendLine($"FECHA:      {DateTime.Now:dd/MM/yyyy HH:mm}");
            sb.AppendLine($"DOC:        {PagoActual.IdPago}");
            sb.AppendLine($"EMPLEADO:   {RolDetalle.NombreEmpleado}");
            if (EmpleadoSeleccionado != null) sb.AppendLine($"CÉDULA:     {EmpleadoSeleccionado.EmpCedula}");
            sb.AppendLine("--------------------------------------------------");
            sb.AppendLine("");
            sb.AppendLine("  1. INGRESOS (+)");
            sb.AppendLine("  ---------------");
            sb.AppendLine(string.Format("  {0,-30} {1,15:C2}", "Sueldo Base Mensual", RolDetalle.EmpSueldo));
            foreach (var b in BonosAplicados)
            {
                string nombre = b.Descripcion.Length > 28 ? b.Descripcion.Substring(0, 28) + ".." : b.Descripcion;
                sb.AppendLine(string.Format("  {0,-30} {1,15:C2}", nombre, b.BxeValor));
            }
            sb.AppendLine("");
            sb.AppendLine("  2. EGRESOS (-)");
            sb.AppendLine("  --------------");
            sb.AppendLine(string.Format("  {0,-30} {1,15:C2}", "Aporte IESS (9.45%)", iess));
            foreach (var d in DescuentosAplicados)
            {
                string nombre = d.Descripcion.Length > 28 ? d.Descripcion.Substring(0, 28) + ".." : d.Descripcion;
                sb.AppendLine(string.Format("  {0,-30} {1,15:C2}", nombre, d.DxeValor));
            }
            sb.AppendLine("");
            sb.AppendLine("==================================================");
            sb.AppendLine(string.Format("  {0,-30} {1,15:C2}", "TOTAL A PAGAR:", RolDetalle.EmpValorNeto));
            sb.AppendLine("==================================================");
            sb.AppendLine("");
            sb.AppendLine("");
            sb.AppendLine("      __________________________");
            sb.AppendLine("           FIRMA RESPONSABLE");
            AsientoTexto = sb.ToString();
        }
    }
}