using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using SDV.UI.Services;

namespace SDV.UI.Views
{
    public partial class CustomMessageBox : Window
    {
        // Esta propiedad guardará la respuesta del usuario (Yes, No, OK)
        public MessageDialogResult Result { get; private set; }

        // Constructor para mensajes simples (OK)
        public CustomMessageBox(string title, string message, MessageDialogType type)
        {
            InitializeComponent();
            SetupMessage(title, message, type);
        }

        // Constructor para mensajes de confirmación (Yes/No)
        public CustomMessageBox(string title, string message)
        {
            InitializeComponent();
            SetupMessage(title, message, MessageDialogType.Confirmation);
        }

        private void SetupMessage(string title, string message, MessageDialogType type)
        {
            TitleText.Text = title;
            MessageText.Text = message;

            // Define el estilo y los botones según el tipo de mensaje
            switch (type)
            {
                case MessageDialogType.Information:
                    IconText.Text = "ℹ️";
                    IconText.Foreground = (Brush)Application.Current.Resources["PrimaryBrush"];
                    BtnOKYes.Content = "ACEPTAR";
                    BtnNoCancel.Visibility = Visibility.Collapsed;
                    break;

                case MessageDialogType.Warning:
                    IconText.Text = "⚠️";
                    IconText.Foreground = new SolidColorBrush(Color.FromRgb(243, 156, 18)); // Naranja
                    BtnOKYes.Content = "ACEPTAR";
                    BtnNoCancel.Visibility = Visibility.Collapsed;
                    break;

                case MessageDialogType.Error:
                    IconText.Text = "❌";
                    IconText.Foreground = (Brush)Application.Current.Resources["DangerBrush"];
                    BtnOKYes.Content = "ACEPTAR";
                    BtnNoCancel.Visibility = Visibility.Collapsed;
                    break;

                case MessageDialogType.Confirmation:
                    IconText.Text = "❓";
                    IconText.Foreground = (Brush)Application.Current.Resources["SecondaryBrush"];
                    BtnOKYes.Content = "SÍ, CONTINUAR";
                    BtnNoCancel.Content = "NO";
                    BtnNoCancel.Visibility = Visibility.Visible;
                    break;
            }
        }

        private void BtnOKYes_Click(object sender, RoutedEventArgs e)
        {
            if (BtnNoCancel.Visibility == Visibility.Visible)
                Result = MessageDialogResult.Yes;
            else
                Result = MessageDialogResult.OK;

            this.DialogResult = true; // Esto es importante para ShowDialog()
            this.Close();             // <--- ESTO CIERRA EL MENSAJE
        }

        private void BtnNoCancel_Click(object sender, RoutedEventArgs e)
        {
            Result = MessageDialogResult.No;
            this.DialogResult = false;
            this.Close();
        }
    }

    // Enumeración temporal para tipos de mensajes
    public enum MessageDialogType
    {
        Information,
        Warning,
        Error,
        Confirmation
    }
}
