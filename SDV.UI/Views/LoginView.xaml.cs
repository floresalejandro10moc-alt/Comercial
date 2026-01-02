using SDV.UI.ViewModels;
using System.Windows;
using System.Windows.Input;

namespace SDV.UI.Views
{
    public partial class LoginView : Window
    {
        private readonly LoginViewModel _vm;

        public LoginView()
        {
            InitializeComponent();
            _vm = new LoginViewModel();
            DataContext = _vm;
        }

        // ESTE EVENTO ES EL QUE HACE QUE EL BOTÓN FUNCIONE
        private async void BtnLogin_Click(object sender, RoutedEventArgs e)
        {
            // Enviamos la contraseña desde el PasswordBox
            await _vm.Ingresar(txtPass.Password, this);
        }

        private void BtnSalir_Click(object sender, RoutedEventArgs e)
        {
            Application.Current.Shutdown();
        }
        private void BtnOlvido_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Estamos trabajando en esta funcionalidad.\nPor favor contacte al administrador.",
                            "En Desarrollo",
                            MessageBoxButton.OK,
                            MessageBoxImage.Information);
        }
    }
}