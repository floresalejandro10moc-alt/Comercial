using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SDV.DataAccess.Repositories;
using SDV.UI.Services;
using SDV.UI.Views;
using System.Threading.Tasks;
using System.Windows;

namespace SDV.UI.ViewModels
{
    public partial class LoginViewModel : ObservableObject
    {
        private readonly UsuarioRepository _repo = new UsuarioRepository();

        [ObservableProperty] private string _usuario = string.Empty;
        [ObservableProperty] private string _mensajeError = string.Empty;
        [ObservableProperty] private bool _isBusy = false;

        public async Task Ingresar(string password, Window window)
        {
            if (string.IsNullOrWhiteSpace(Usuario) || string.IsNullOrWhiteSpace(password))
            {
                MessageBox.Show("Ingrese usuario y contraseña", "Aviso");
                return;
            }

            IsBusy = true;
            MensajeError = "Verificando...";

            try
            {
                // DEBUG: Para saber que sí llegó aquí
                // MessageBox.Show($"Intentando conectar como: {Usuario}", "Depuración");

                var (emp, idRol, nombreRol) = await _repo.LoginAsync(Usuario, password);

                if (emp != null)
                {
                    SesionActual.Iniciar(emp, idRol, nombreRol);

                    var main = new MainWindow();
                    main.Show();
                    window.Close();
                }
                else
                {
                    MensajeError = "Credenciales incorrectas.";
                    MessageBox.Show("Usuario o contraseña incorrectos.\nO el usuario no tiene ROL asignado.", "Error de Login");
                }
            }
            catch (System.Exception ex)
            {
                MensajeError = "Error de conexión";
                MessageBox.Show($"Error Crítico:\n{ex.Message}", "Error BD");
            }
            finally
            {
                IsBusy = false;
            }
        }

        [RelayCommand]
        public void Salir()
        {
            Application.Current.Shutdown();
        }
    }
}