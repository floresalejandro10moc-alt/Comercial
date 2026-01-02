using System.Windows;
using SDV.UI.Views;
using SDV.UI.Services; // Necesario para SesionActual

namespace SDV.UI
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void BtnCerrarSesion_Click(object sender, RoutedEventArgs e)
        {
            var resultado = MessageBox.Show(
                "¿Está seguro que desea cerrar sesión?",
                "Confirmar Salida",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (resultado == MessageBoxResult.Yes)
            {
                // 1. Limpiar los datos del usuario estático
                SesionActual.Cerrar();

                // 2. Abrir Login
                var login = new LoginView();
                login.Show();

                // 3. Cerrar esta ventana
                this.Close();
            }
        }
    }
}