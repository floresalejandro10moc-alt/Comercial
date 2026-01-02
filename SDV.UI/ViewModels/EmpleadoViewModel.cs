using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SDV.DataAccess.Repositories;
using SDV.Model.DTOs;
using SDV.Model.Entities;
using SDV.UI.Services; // Importante
using SDV.UI.Views;
using System;
using System.Collections.ObjectModel;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;

namespace SDV.UI.ViewModels
{
    public partial class EmpleadoViewModel : ObservableObject
    {
        private readonly EmpleadoRepository _repo = new EmpleadoRepository();
        private readonly IMessageDialogService _dialogService; // Servicio de mensajes
        private const int REGISTROS_POR_PAGINA = 10;

        // --- PROPIEDADES ---
        [ObservableProperty] private int _paginaActual = 1;
        [ObservableProperty] private int _totalRegistros;
        [ObservableProperty] private string? _infoPaginacion = "Cargando...";
        [ObservableProperty] private string? _textoBusqueda = string.Empty;

        [ObservableProperty] private ObservableCollection<Empleado> _listaEmpleados = new();
        [ObservableProperty] private ObservableCollection<ItemCatalogo> _listaRoles = new();
        [ObservableProperty] private ObservableCollection<ItemCatalogo> _listaDepartamentos = new();

        private Empleado? _empleadoOriginal; // Para comparar cambios
        [ObservableProperty] private Empleado _empleadoActual = new();

        public EmpleadoViewModel()
        {
            _dialogService = new MessageDialogService(); // Inicializamos el servicio
            Task.Run(async () => await CargarInicial());
        }

        private async Task CargarInicial()
        {
            var roles = await _repo.GetRolesAsync();
            var deptos = await _repo.GetDepartamentosAsync();
            await CargarPagina();

            Application.Current.Dispatcher.Invoke(() =>
            {
                ListaRoles = new ObservableCollection<ItemCatalogo>(roles);
                ListaDepartamentos = new ObservableCollection<ItemCatalogo>(deptos);
            });
        }

        // --- MÉTODOS Y COMANDOS ---

        [RelayCommand]
        public async Task CargarPagina()
        {
            var (datos, total) = await _repo.GetPaginadoAsync(PaginaActual, REGISTROS_POR_PAGINA);
            Application.Current.Dispatcher.Invoke(() =>
            {
                ListaEmpleados = new ObservableCollection<Empleado>(datos);
                TotalRegistros = total;
                InfoPaginacion = $"Pág. {PaginaActual} de {Math.Ceiling((double)total / REGISTROS_POR_PAGINA)} (Total: {total})";
            });
        }

        [RelayCommand]
        public async Task Buscar()
        {
            if (string.IsNullOrWhiteSpace(TextoBusqueda))
            {
                await CargarPagina();
                return;
            }
            var resultado = await _repo.BuscarAsync(TextoBusqueda);
            Application.Current.Dispatcher.Invoke(() =>
            {
                ListaEmpleados = new ObservableCollection<Empleado>(resultado);
                InfoPaginacion = $"Resultados encontrados: {ListaEmpleados.Count}";
                PaginaActual = 1;
            });
        }

        [RelayCommand]
        public void Nuevo()
        {
            EmpleadoActual = new Empleado
            {
                EmpSueldo = 460,
                EstadoEmp = "ACT",
                EmpFechaNacimiento = DateTime.Now.AddYears(-18)
            };
            _empleadoOriginal = null; // Es nuevo, no hay original
            AbrirFormulario();
        }

        [RelayCommand]
        public void Editar(Empleado emp)
        {
            // Clonamos
            EmpleadoActual = new Empleado
            {
                IdEmpleado = emp.IdEmpleado,
                EmpCedula = emp.EmpCedula,
                EmpNombre1 = emp.EmpNombre1,
                EmpNombre2 = emp.EmpNombre2,
                EmpApellido1 = emp.EmpApellido1,
                EmpApellido2 = emp.EmpApellido2,
                EmpSexo = emp.EmpSexo,
                EmpFechaNacimiento = emp.EmpFechaNacimiento,
                EmpMail = emp.EmpMail,
                EmpSueldo = emp.EmpSueldo,
                IdRol = emp.IdRol,
                IdDepartamento = emp.IdDepartamento,
                EstadoEmp = emp.EstadoEmp
            };
            _empleadoOriginal = emp; // Guardamos referencia para comparar
            AbrirFormulario();
        }

        private void AbrirFormulario()
        {
            var ventana = new FormularioEmpleado();
            ventana.DataContext = this;
            ventana.ShowDialog();
        }

        [RelayCommand]
        public async Task Guardar(Window? win)
        {
            // 1. Validaciones locales (Formato, Arrobas, Módulo 10, etc.)
            if (!Validar()) return;

            try
            {
                if (EmpleadoActual.IdEmpleado > 0)
                {
                    // ==========================================================
                    // LOGICA DE EDICIÓN (UPDATE)
                    // ==========================================================

                    // Validar inmutabilidad de Cédula (Seguridad extra)
                    if (_empleadoOriginal != null && EmpleadoActual.EmpCedula != _empleadoOriginal.EmpCedula)
                    {
                        _dialogService.ShowMessage("Campo Inmutable", "La Cédula no puede ser modificada en modo edición.");
                        return;
                    }

                    // Confirmar cambios sensibles
                    bool sueldoCambio = _empleadoOriginal != null && EmpleadoActual.EmpSueldo != _empleadoOriginal.EmpSueldo;
                    bool fechaCambio = _empleadoOriginal != null && EmpleadoActual.EmpFechaNacimiento.Date != _empleadoOriginal.EmpFechaNacimiento.Date;

                    if (sueldoCambio || fechaCambio)
                    {
                        string mensaje = "Ha editado campos sensibles:\n";
                        if (sueldoCambio) mensaje += "- Sueldo\n";
                        if (fechaCambio) mensaje += "- Fecha de Nacimiento\n";
                        mensaje += "\n¿Desea continuar?";

                        var resp = _dialogService.ShowConfirmation("Confirmación", mensaje);
                        if (resp == MessageDialogResult.No) return;
                    }

                    await _repo.UpdateAsync(EmpleadoActual);
                    _dialogService.ShowMessage("Éxito", "Datos actualizados correctamente.");
                }
                else
                {
                    // ==========================================================
                    // LOGICA DE NUEVO EMPLEADO (INSERT)
                    // ==========================================================

                    // ---> AQUÍ ESTÁ LA VALIDACIÓN DE UNICIDAD <---
                    // Antes de insertar, preguntamos al Repo si la cédula ya existe en la BD
                    bool existe = await _repo.ExisteCedulaAsync(EmpleadoActual.EmpCedula);

                    if (existe)
                    {
                        _dialogService.ShowMessage("Duplicado", $"La cédula {EmpleadoActual.EmpCedula} ya se encuentra registrada en el sistema.");
                        return; // IMPORTANTE: Detenemos el guardado aquí
                    }

                    await _repo.InsertAsync(EmpleadoActual);
                    _dialogService.ShowMessage("Éxito", "Nuevo empleado registrado correctamente.");
                }

                // --- CIERRE DE VENTANA Y REFRESCO ---
                if (win != null)
                {
                    win.Close();
                }

                await CargarPagina();
            }
            catch (Exception ex)
            {
                _dialogService.ShowMessage("Error Crítico", $"Ocurrió un error al guardar: {ex.Message}");
            }
        }

        // AHORA ELIMINAR TAMBIÉN ES BONITO
        [RelayCommand]
        public async Task EliminarEmpleado(Empleado emp)
        {
            var result = _dialogService.ShowConfirmation("Eliminar", $"¿Está seguro de inactivar a {emp.NombreCompleto}?");

            if (result == MessageDialogResult.Yes)
            {
                await _repo.DeleteAsync(emp.IdEmpleado);
                _dialogService.ShowMessage("Éxito", "Empleado eliminado correctamente.");
                await CargarPagina();
            }
        }

        // VALIDACIONES CON MENSAJES BONITOS
        private bool EsCedulaValida(string cedula)
        {
            // 1. Validaciones básicas de longitud y nulidad
            if (string.IsNullOrWhiteSpace(cedula) || cedula.Length != 10) return false;

            // 2. Verificar que solo sean números
            if (!long.TryParse(cedula, out _)) return false;

            // 3. Validar código de provincia (dos primeros dígitos, 01-24 o 30 para extranjeros)
            int provincia = int.Parse(cedula.Substring(0, 2));
            if (!((provincia >= 1 && provincia <= 24) || provincia == 30)) return false;

            // 4. Validar tercer dígito (debe ser menor a 6 para personas naturales)
            int tercerDigito = int.Parse(cedula.Substring(2, 1));
            if (tercerDigito >= 6) return false; // Nota: RUCs públicos/privados usan 6 y 9, pero cédula personal es < 6

            // 5. Algoritmo Módulo 10 (Último dígito verificador)
            int[] coeficientes = { 2, 1, 2, 1, 2, 1, 2, 1, 2 };
            int total = 0;
            int digitoVerificador = int.Parse(cedula.Substring(9, 1));

            for (int i = 0; i < 9; i++)
            {
                int valor = int.Parse(cedula.Substring(i, 1)) * coeficientes[i];

                if (valor >= 10)
                {
                    valor = valor - 9;
                }
                total += valor;
            }

            int digitoCalculado = total % 10 == 0 ? 0 : 10 - (total % 10);

            return digitoCalculado == digitoVerificador;
        }
        private bool Validar()
        {
            // ---------------------------------------------------------
            // 1. CÉDULA ECUATORIANA (Lógica Real)
            // ---------------------------------------------------------
            // Nota: Usamos EmpleadoActual.EmpCedula ?? "" para evitar error si es null
            if (!EsCedulaValida(EmpleadoActual.EmpCedula ?? ""))
            {
                _dialogService.ShowMessage("Validación", "La cédula ingresada no es válida o no existe en Ecuador.");
                return false;
            }

            // 2. Edad
            var edad = DateTime.Today.Year - EmpleadoActual.EmpFechaNacimiento.Year;
            if (EmpleadoActual.EmpFechaNacimiento.Date > DateTime.Today.AddYears(-edad)) edad--;

            if (edad < 18)
            {
                _dialogService.ShowMessage("Validación", $"El empleado tiene {edad} años. Debe ser mayor de edad (+18).");
                return false;
            }

            // 3. Nombres y Apellidos
            var regexLetras = @"^[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]+$";
            if (!Regex.IsMatch(EmpleadoActual.EmpNombre1 ?? "", regexLetras) ||
                (!string.IsNullOrEmpty(EmpleadoActual.EmpNombre2) && !Regex.IsMatch(EmpleadoActual.EmpNombre2, regexLetras)) ||
                !Regex.IsMatch(EmpleadoActual.EmpApellido1 ?? "", regexLetras) ||
                (!string.IsNullOrEmpty(EmpleadoActual.EmpApellido2) && !Regex.IsMatch(EmpleadoActual.EmpApellido2, regexLetras)))
            {
                _dialogService.ShowMessage("Validación", "Los nombres y apellidos solo pueden contener letras.");
                return false;
            }

            // 4. Correo Electrónico (Tu lógica de las arrobas)
            if (string.IsNullOrWhiteSpace(EmpleadoActual.EmpMail))
            {
                _dialogService.ShowMessage("Validación", "El correo electrónico es obligatorio.");
                return false;
            }

            if (EmpleadoActual.EmpMail.Count(c => c == '@') > 1)
            {
                _dialogService.ShowMessage("Validación", "El correo es incorrecto: No puede contener más de una '@'.");
                return false;
            }

            var regexEmail = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";
            if (!Regex.IsMatch(EmpleadoActual.EmpMail, regexEmail))
            {
                _dialogService.ShowMessage("Validación", "El formato del correo electrónico no es válido.");
                return false;
            }

            // 5. Sueldo
            if (EmpleadoActual.EmpSueldo <= 0)
            {
                _dialogService.ShowMessage("Validación", "El sueldo debe ser mayor a $0.00");
                return false;
            }

            // 6. Combos
            if (string.IsNullOrEmpty(EmpleadoActual.IdRol) || string.IsNullOrEmpty(EmpleadoActual.IdDepartamento))
            {
                _dialogService.ShowMessage("Validación", "Debe seleccionar un Cargo y un Departamento.");
                return false;
            }

            return true;
        }

        // Paginación
        [RelayCommand]
        public async Task SiguientePagina() { PaginaActual++; await CargarPagina(); }
        [RelayCommand]
        public async Task AnteriorPagina() { if (PaginaActual > 1) { PaginaActual--; await CargarPagina(); } }
    }
}