using CommunityToolkit.Mvvm.ComponentModel;
using SDV.Model.Entities;
using SDV.DataAccess.Repositories;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using System.Linq;

namespace SDV.UI.ViewModels
{
    public partial class LibroDiarioViewModel : ObservableObject
    {
        private readonly ContabilidadRepository _repo = new();
        [ObservableProperty] private string _filtroAsientos = "";
        [ObservableProperty] private AsientoContable? _asientoSeleccionado;
        [ObservableProperty] private decimal _totalDebeDetalle;
        [ObservableProperty] private decimal _totalHaberDetalle;

        public ObservableCollection<AsientoContable> Asientos { get; set; } = new();
        public ObservableCollection<CuentaXAsiento> DetalleAsiento { get; set; } = new();

        public LibroDiarioViewModel() { _ = CargarDatosAsync(); }

        private async Task CargarDatosAsync()
        {
            var asientos = await _repo.GetAsientosHeadersAsync(FiltroAsientos);
            Asientos.Clear();
            foreach (var a in asientos) Asientos.Add(a);
        }

        partial void OnAsientoSeleccionadoChanged(AsientoContable? value)
        {
            if (value != null) _ = CargarDetallesAsync(value.IdAsientoContable);
        }

        private async Task CargarDetallesAsync(string id)
        {
            var detalles = (await _repo.GetDetallesAsientoAsync(id)).ToList();
            DetalleAsiento.Clear();
            TotalDebeDetalle = detalles.Sum(x => x.CxaMontoDebe);
            TotalHaberDetalle = detalles.Sum(x => x.CxaMontoHaber);
            foreach (var d in detalles) DetalleAsiento.Add(d);
        }

        partial void OnFiltroAsientosChanged(string value) => _ = CargarDatosAsync();
    }
}