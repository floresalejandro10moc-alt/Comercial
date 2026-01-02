using System.Windows;
using System.Windows.Input; // <--- NECESARIO: Agrega esta línea para MouseButtonEventArgs

namespace SDV.UI.Views
{
    public partial class FormularioEmpleado : Window
    {
        public FormularioEmpleado()
        {
            InitializeComponent();
        }

        // Este método se activa al hacer clic en la cédula
        private void TxtCedula_Click(object sender, MouseButtonEventArgs e)
        {
            // Verificamos si la caja tiene el IsReadOnly activado (Modo Edición)
            if (TxtCedula.IsReadOnly)
            {
                MessageBox.Show("El número de cédula no se puede editar porque identifica al empleado.",
                                "Campo Bloqueado",
                                MessageBoxButton.OK,
                                MessageBoxImage.Information);
            }
        }
    }
}