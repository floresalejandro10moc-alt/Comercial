using CommunityToolkit.Mvvm.ComponentModel;
using SDV.Model.Entities;
using SDV.DataAccess.Repositories;
using System.Collections.ObjectModel;
using System.Threading.Tasks;

namespace SDV.UI.ViewModels
{
    public partial class PlanCuentasViewModel : ObservableObject
    {
        private readonly ContabilidadRepository _repo = new();
        [ObservableProperty] private string _filtroCuentas = "";
        public ObservableCollection<CuentaContable> PlanCuentas { get; set; } = new();

        public PlanCuentasViewModel() { _ = CargarDatosAsync(); }

        private async Task CargarDatosAsync()
        {
            var cuentas = await _repo.GetPlanCuentasAsync(FiltroCuentas);
            PlanCuentas.Clear();
            foreach (var c in cuentas) PlanCuentas.Add(c);
        }

        partial void OnFiltroCuentasChanged(string value) => _ = CargarDatosAsync();
    }
}