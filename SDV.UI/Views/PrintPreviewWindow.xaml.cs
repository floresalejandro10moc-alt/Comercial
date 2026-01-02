using Microsoft.Win32;
using System;
using System.IO;
using System.IO.Packaging;
using System.Windows;
using System.Windows.Documents;
using System.Windows.Xps;
using System.Windows.Xps.Packaging;
using System.Windows.Xps.Serialization;

namespace SDV.UI.Views
{
    public partial class PrintPreviewWindow : Window
    {
        private readonly FlowDocument _documentoOriginal;

        public PrintPreviewWindow(FlowDocument doc)
        {
            InitializeComponent();
            _documentoOriginal = doc;
            CargarDocumentoEnVisor(doc);
        }

        private void CargarDocumentoEnVisor(FlowDocument doc)
        {
            // 1. Configuración de página
            doc.PageWidth = 793.7;
            doc.PageHeight = 1122.5;
            doc.ColumnWidth = 793.7;

            // 2. Preparar el flujo de memoria
            MemoryStream ms = new MemoryStream();
            Package pkg = Package.Open(ms, FileMode.Create, FileAccess.ReadWrite);

            // --- CORRECCIÓN AQUÍ ---
            Uri uri = new Uri("pack://temp.xps");

            // Verificamos si ya existe en el almacén global y lo borramos si es así
            if (PackageStore.GetPackage(uri) != null)
            {
                PackageStore.RemovePackage(uri);
            }

            // Ahora sí podemos agregarlo sin que lance la excepción
            PackageStore.AddPackage(uri, pkg);
            // -----------------------

            using (XpsDocument xpsDoc = new XpsDocument(pkg, CompressionOption.NotCompressed, uri.ToString()))
            {
                XpsSerializationManager xpssm = new XpsSerializationManager(new XpsPackagingPolicy(xpsDoc), false);
                xpssm.SaveAsXaml(((IDocumentPaginatorSource)doc).DocumentPaginator);
                Previewer.Document = xpsDoc.GetFixedDocumentSequence();
            }

            // Ajustar zoom automático
            Dispatcher.BeginInvoke(new Action(() => {
                Previewer.FitToWidth();
            }), System.Windows.Threading.DispatcherPriority.ApplicationIdle);
        }

        private void BtnImprimirModerno_Click(object sender, RoutedEventArgs e)
        {
            System.Windows.Controls.PrintDialog pd = new System.Windows.Controls.PrintDialog();
            if (pd.ShowDialog() == true)
            {
                pd.PrintDocument(((IDocumentPaginatorSource)_documentoOriginal).DocumentPaginator, "Rol de Pago SDV");
            }
        }

        private void BtnExportarPDF_Click(object sender, RoutedEventArgs e)
        {
            // La forma más fácil y lógica en WPF sin librerías externas es usar la impresora de PDF de Windows
            MessageBox.Show("Para guardar como PDF, seleccione la impresora 'Microsoft Print to PDF' en el siguiente diálogo.",
                            "Guardar como PDF", MessageBoxButton.OK, MessageBoxImage.Information);

            BtnImprimirModerno_Click(sender, e);
        }
    }
}