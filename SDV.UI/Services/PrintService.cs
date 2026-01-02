using SDV.Model.Entities;
using SDV.UI.Views;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Documents;
using System.Windows.Media;

namespace SDV.UI.Services
{
    public class PrintService
    {
        public void ImprimirRolIndividual(Pago cabecera, PagxEmp empleado, IEnumerable<BonxEmpxPag> bonos, IEnumerable<DesxEmpxPag> descuentos, string cedula, string cargo)
        {
            if (empleado == null) return;
            var listaBonos = bonos?.ToList() ?? new List<BonxEmpxPag>();
            var listaDescuentos = descuentos?.ToList() ?? new List<DesxEmpxPag>();

            FlowDocument doc = new FlowDocument
            {
                PagePadding = new Thickness(50),
                ColumnWidth = 800, // Ancho fijo para evitar estiramientos
                FontFamily = new FontFamily("Segoe UI"),
                FontSize = 11
            };

            // 1. HEADER
            Paragraph header = new Paragraph();
            header.TextAlignment = TextAlignment.Center;
            header.Margin = new Thickness(0, 0, 0, 20);
            header.Inlines.Add(new Run("SISTEMA COMERCIAL SDV") { FontSize = 18, FontWeight = FontWeights.Bold });
            header.Inlines.Add(new LineBreak());
            header.Inlines.Add(new Run("ROL DE PAGOS INDIVIDUAL") { FontSize = 13, FontWeight = FontWeights.SemiBold });
            header.Inlines.Add(new LineBreak());
            header.Inlines.Add(new Run(cabecera?.PagDescripcion ?? ("Periodo: " + empleado.IdPago)) { FontSize = 11, Foreground = Brushes.DimGray });
            doc.Blocks.Add(header);

            // 2. INFO EMPLEADO (En tabla para orden)
            Table infoTable = new Table() { Margin = new Thickness(0, 0, 0, 20) };
            infoTable.Columns.Add(new TableColumn() { Width = new GridLength(100) });
            infoTable.Columns.Add(new TableColumn() { Width = new GridLength(250) });
            infoTable.Columns.Add(new TableColumn() { Width = new GridLength(100) });
            infoTable.Columns.Add(new TableColumn() { Width = new GridLength(200) });

            TableRowGroup infoGroup = new TableRowGroup();
            TableRow r1 = new TableRow();
            r1.Cells.Add(CellTexto("Empleado:", FontWeights.Bold));
            r1.Cells.Add(CellTexto(empleado.NombreEmpleado?.ToUpper() ?? ""));
            r1.Cells.Add(CellTexto("Cédula:", FontWeights.Bold));
            r1.Cells.Add(CellTexto(cedula ?? "S/N"));
            infoGroup.Rows.Add(r1);

            TableRow r2 = new TableRow();
            r2.Cells.Add(CellTexto("Cargo:", FontWeights.Bold));
            r2.Cells.Add(CellTexto(cargo?.ToUpper() ?? "NO ASIGNADO"));
            r2.Cells.Add(CellTexto("Periodo:", FontWeights.Bold));
            r2.Cells.Add(CellTexto(cabecera?.IdPago ?? empleado.IdPago));
            infoGroup.Rows.Add(r2);

            infoTable.RowGroups.Add(infoGroup);
            doc.Blocks.Add(infoTable);

            // 3. TABLA PRINCIPAL (5 COLUMNAS PARA SEPARACIÓN REAL)
            Table mainTable = new Table() { CellSpacing = 0, BorderBrush = Brushes.Black, BorderThickness = new Thickness(0, 1, 0, 1) };
            mainTable.Columns.Add(new TableColumn() { Width = new GridLength(240) }); // Ingreso Desc
            mainTable.Columns.Add(new TableColumn() { Width = new GridLength(80) });  // Ingreso Valor
            mainTable.Columns.Add(new TableColumn() { Width = new GridLength(40) });  // ESPACIO VACÍO (Gutter)
            mainTable.Columns.Add(new TableColumn() { Width = new GridLength(240) }); // Egreso Desc
            mainTable.Columns.Add(new TableColumn() { Width = new GridLength(80) });  // Egreso Valor

            TableRowGroup mainGroup = new TableRowGroup();

            // Encabezado de la tabla con fondo
            TableRow hRow = new TableRow();
            hRow.Background = new SolidColorBrush(Color.FromRgb(240, 240, 240));
            hRow.Cells.Add(CellTexto("INGRESOS", FontWeights.Bold, TextAlignment.Center));
            hRow.Cells.Add(CellTexto("VALOR", FontWeights.Bold, TextAlignment.Center));
            hRow.Cells.Add(new TableCell()); // Celda vacía del medio
            hRow.Cells.Add(CellTexto("EGRESOS", FontWeights.Bold, TextAlignment.Center));
            hRow.Cells.Add(CellTexto("VALOR", FontWeights.Bold, TextAlignment.Center));
            mainGroup.Rows.Add(hRow);

            // Preparar listas
            var itemsIng = new List<dynamic> { new { C = "Sueldo Base", V = empleado.EmpSueldo } };
            foreach (var b in listaBonos) itemsIng.Add(new { C = b.Descripcion, V = b.BxeValor });

            var itemsEgr = new List<dynamic>();
            decimal iess = Math.Round(empleado.EmpSueldo * 0.0945m, 2);
            itemsEgr.Add(new { C = "Aporte IESS (9.45%)", V = iess });
            foreach (var d in listaDescuentos) itemsEgr.Add(new { C = d.Descripcion, V = d.DxeValor });

            int maxRows = Math.Max(itemsIng.Count, itemsEgr.Count);

            for (int i = 0; i < maxRows; i++)
            {
                TableRow row = new TableRow();
                // Lado Ingresos
                if (i < itemsIng.Count)
                {
                    row.Cells.Add(CellTexto(itemsIng[i].C));
                    row.Cells.Add(CellTexto(((decimal)itemsIng[i].V).ToString("N2"), null, TextAlignment.Right));
                }
                else { row.Cells.Add(new TableCell()); row.Cells.Add(new TableCell()); }

                row.Cells.Add(new TableCell()); // ESPACIO CENTRAL

                // Lado Egresos
                if (i < itemsEgr.Count)
                {
                    row.Cells.Add(CellTexto(itemsEgr[i].C));
                    row.Cells.Add(CellTexto(((decimal)itemsEgr[i].V).ToString("N2"), null, TextAlignment.Right));
                }
                else { row.Cells.Add(new TableCell()); row.Cells.Add(new TableCell()); }

                mainGroup.Rows.Add(row);
            }

            // Fila de Totales
            TableRow tRow = new TableRow() { Background = Brushes.GhostWhite, FontWeight = FontWeights.Bold };
            tRow.Cells.Add(CellTexto("TOTAL INGRESOS:", null, TextAlignment.Right));
            tRow.Cells.Add(CellTexto((empleado.EmpSueldo + empleado.EmpBonificaciones).ToString("N2"), null, TextAlignment.Right));
            tRow.Cells.Add(new TableCell()); // Espacio central
            tRow.Cells.Add(CellTexto("TOTAL EGRESOS:", null, TextAlignment.Right));
            tRow.Cells.Add(CellTexto(empleado.EmpDescuentos.ToString("N2"), null, TextAlignment.Right));
            mainGroup.Rows.Add(tRow);

            mainTable.RowGroups.Add(mainGroup);
            doc.Blocks.Add(mainTable);

            // Neto (Alineado a la derecha del todo)
            Paragraph neto = new Paragraph();
            neto.TextAlignment = TextAlignment.Right;
            neto.Margin = new Thickness(0, 30, 0, 50);
            neto.Inlines.Add(new Run("LÍQUIDO A RECIBIR:   ") { FontSize = 12 });
            neto.Inlines.Add(new Run($"{empleado.EmpValorNeto:C2}") { FontSize = 20, FontWeight = FontWeights.Bold, Foreground = new SolidColorBrush(Color.FromRgb(44, 62, 80)) });
            doc.Blocks.Add(neto);

            // Firmas
            Table firmas = new Table();
            firmas.Columns.Add(new TableColumn() { Width = new GridLength(1, GridUnitType.Star) });
            firmas.Columns.Add(new TableColumn() { Width = new GridLength(1, GridUnitType.Star) });
            TableRowGroup fGroup = new TableRowGroup();
            TableRow fRow = new TableRow();
            fRow.Cells.Add(CellFirma("Empleador / RRHH"));
            fRow.Cells.Add(CellFirma("Recibí Conforme"));
            fGroup.Rows.Add(fRow);
            firmas.RowGroups.Add(fGroup);
            doc.Blocks.Add(firmas);

            // Abrir vista previa
            SDV.UI.Views.PrintPreviewWindow preview = new SDV.UI.Views.PrintPreviewWindow(doc);
            preview.ShowDialog();
        }

        private TableCell CellTexto(string t, FontWeight? w = null, TextAlignment a = TextAlignment.Left)
        {
            var p = new Paragraph(new Run(t ?? "")) { FontWeight = w ?? FontWeights.Normal, TextAlignment = a, Padding = new Thickness(5, 2, 5, 2) };
            return new TableCell(p);
        }

        private TableCell CellFirma(string t)
        {
            var p = new Paragraph();
            p.TextAlignment = TextAlignment.Center;
            p.Inlines.Add(new Run("\n\n___________________________\n"));
            p.Inlines.Add(new Run(t) { FontWeight = FontWeights.Bold });
            return new TableCell(p);
        }
        public void ImprimirResumenMensual(string periodo, List<PagxEmp> listaRoles)
        {
            FlowDocument doc = new FlowDocument { PagePadding = new Thickness(50), FontFamily = new FontFamily("Segoe UI") };

            // Encabezado
            doc.Blocks.Add(new Paragraph(new Run("REPORTE CONSOLIDADO DE NÓMINA") { FontSize = 18, FontWeight = FontWeights.Bold, Foreground = Brushes.DarkBlue }));
            doc.Blocks.Add(new Paragraph(new Run($"PERIODO: {periodo}") { FontSize = 14 }));

            // Tabla de resumen
            Table table = new Table { CellSpacing = 0, BorderBrush = Brushes.Black, BorderThickness = new Thickness(1) };
            table.Columns.Add(new TableColumn { Width = new GridLength(250) }); // Empleado
            table.Columns.Add(new TableColumn { Width = new GridLength(100) }); // Sueldo
            table.Columns.Add(new TableColumn { Width = new GridLength(100) }); // Neto

            TableRowGroup group = new TableRowGroup();
            // Cabecera de tabla
            group.Rows.Add(new TableRow
            {
                Cells = {
                        new TableCell(new Paragraph(new Run("COLABORADOR") { FontWeight = FontWeights.Bold })),
                        new TableCell(new Paragraph(new Run("SUELDO") { FontWeight = FontWeights.Bold })),
                        new TableCell(new Paragraph(new Run("NETO A PAGAR") { FontWeight = FontWeights.Bold }))
                         }
            });

            foreach (var r in listaRoles)
            {
                group.Rows.Add(new TableRow
                {
                    Cells = {
                            new TableCell(new Paragraph(new Run(r.NombreEmpleado))),
                            new TableCell(new Paragraph(new Run(r.EmpSueldo.ToString("C2")))),
                            new TableCell(new Paragraph(new Run(r.EmpValorNeto.ToString("C2"))))
                         }
                });
            }

            // Fila de Totales Finales
            TableRow tRow = new TableRow { Background = Brushes.LightGray };
            tRow.Cells.Add(new TableCell(new Paragraph(new Run("TOTALES") { FontWeight = FontWeights.Bold })));
            tRow.Cells.Add(new TableCell(new Paragraph(new Run(listaRoles.Sum(x => x.EmpSueldo).ToString("C2")) { FontWeight = FontWeights.Bold })));
            tRow.Cells.Add(new TableCell(new Paragraph(new Run(listaRoles.Sum(x => x.EmpValorNeto).ToString("C2")) { FontWeight = FontWeights.Bold })));
            group.Rows.Add(tRow);

            table.RowGroups.Add(group);
            doc.Blocks.Add(table);

            PrintPreviewWindow win = new PrintPreviewWindow(doc);
            win.ShowDialog();
        }
    }
}