using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace SDV.UI.Services
{
    public interface IMessageDialogService
    {
        // Método para mostrar un mensaje simple (OK)
        void ShowMessage(string title, string message);

        // Método para preguntar al usuario (Yes/No)
        MessageDialogResult ShowConfirmation(string title, string message);
    }
}
