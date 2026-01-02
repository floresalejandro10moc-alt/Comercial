using System.Windows.Controls; // <--- OJO AQUÍ

namespace SDV.UI.Views
{
    // DEBE DECIR : UserControl (No Window)
    public partial class GenerarRolView : UserControl
    {
        public GenerarRolView()
        {
            InitializeComponent();
        }

        private void TabControl_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
    }
}
