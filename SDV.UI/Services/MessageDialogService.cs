using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using SDV.UI.Views; // ¡NUEVO USING!

namespace SDV.UI.Services
{
    public class MessageDialogService : IMessageDialogService
    {
        public void ShowMessage(string title, string message)
        {
            // Determinar el tipo de mensaje para el icono
            MessageDialogType type = MessageDialogType.Information;
            if (title.ToLower().Contains("error"))
                type = MessageDialogType.Error;
            else if (title.ToLower().Contains("advertencia") || title.ToLower().Contains("inmutable"))
                type = MessageDialogType.Warning;

            // Abrir la ventana personalizada
            var customBox = new CustomMessageBox(title, message, type);
            customBox.ShowDialog();
        }

        public MessageDialogResult ShowConfirmation(string title, string message)
        {
            // Abrir la ventana personalizada de confirmación
            var customBox = new CustomMessageBox(title, message);
            customBox.ShowDialog();

            // Retorna el resultado que el usuario eligió (Yes/No)
            return customBox.Result;
        }
    }
}
