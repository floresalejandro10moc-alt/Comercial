using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SDV.DataAccess.Repositories;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;

namespace SDV.UI.ViewModels
{
    public partial class NovedadesViewModel : ObservableObject
    {
        private readonly NominaRepository _repo = new NominaRepository();
        private List<dynamic> _bonosMaster = new();
        private List<dynamic> _descuentosMaster = new();

        public ObservableCollection<dynamic> BonosLista { get; set; } = new();
        public ObservableCollection<dynamic> DescuentosLista { get; set; } = new();

        [ObservableProperty] private string _descripcionBono = "";
        [ObservableProperty] private decimal _valorBono;
        [ObservableProperty] private string _descripcionDesc = "";
        [ObservableProperty] private decimal _valorDesc;
        [ObservableProperty] private string _filtroBusquedaBonos = "";
        [ObservableProperty] private string _filtroBusquedaDescuentos = "";

        public NovedadesViewModel()
        {
            _ = CargarDatosAsync();
        }

        private async Task CargarDatosAsync()
        {
            var b = await _repo.GetTodasBonificacionesAsync();
            var d = await _repo.GetTodosDescuentosAsync();
            _bonosMaster = b.ToList();
            _descuentosMaster = d.ToList();
            FiltrarBonos();
            FiltrarDescuentos();
        }

        partial void OnFiltroBusquedaBonosChanged(string value) => FiltrarBonos();
        partial void OnFiltroBusquedaDescuentosChanged(string value) => FiltrarDescuentos();

        private void FiltrarBonos()
        {
            var f = _bonosMaster.Where(x => string.IsNullOrEmpty(FiltroBusquedaBonos) ||
                    x.Descripcion.ToString().Contains(FiltroBusquedaBonos, StringComparison.OrdinalIgnoreCase));
            BonosLista.Clear();
            foreach (var item in f) BonosLista.Add(item);
        }

        private void FiltrarDescuentos()
        {
            var f = _descuentosMaster.Where(x => string.IsNullOrEmpty(FiltroBusquedaDescuentos) ||
                    x.Descripcion.ToString().Contains(FiltroBusquedaDescuentos, StringComparison.OrdinalIgnoreCase));
            DescuentosLista.Clear();
            foreach (var item in f) DescuentosLista.Add(item);
        }

        [RelayCommand]
        public async Task GuardarBono()
        {
            if (!ValidarEntrada(DescripcionBono, ValorBono)) return;
            if (await _repo.InsertarBonificacionAsync(DescripcionBono, ValorBono))
            {
                DescripcionBono = ""; ValorBono = 0;
                await CargarDatosAsync();
            }
        }

        [RelayCommand]
        public async Task GuardarDesc()
        {
            if (!ValidarEntrada(DescripcionDesc, ValorDesc)) return;
            if (await _repo.InsertarDescuentoAsync(DescripcionDesc, ValorDesc))
            {
                DescripcionDesc = ""; ValorDesc = 0;
                await CargarDatosAsync();
            }
        }

        [RelayCommand]
        public async Task EliminarBono(dynamic obj)
        {
            if (MessageBox.Show("¿Eliminar este beneficio?", "Confirmar", MessageBoxButton.YesNo) == MessageBoxResult.Yes)
            {
                await _repo.EliminarBonificacionAsync(obj.Id.ToString());
                await CargarDatosAsync();
            }
        }

        [RelayCommand]
        public async Task EliminarDesc(dynamic obj)
        {
            if (MessageBox.Show("¿Eliminar este descuento?", "Confirmar", MessageBoxButton.YesNo) == MessageBoxResult.Yes)
            {
                await _repo.EliminarDescuentoAsync(obj.Id.ToString());
                await CargarDatosAsync();
            }
        }

        private bool ValidarEntrada(string desc, decimal val)
        {
            if (string.IsNullOrWhiteSpace(desc) || !Regex.IsMatch(desc, @"^[a-zA-ZñÑáéíóúÁÉÍÓÚ ]+$"))
            {
                MessageBox.Show("Descripción inválida (Solo letras).");
                return false;
            }
            if (val <= 0)
            {
                MessageBox.Show("El valor debe ser mayor a cero.");
                return false;
            }
            return true;
        }
    }
}