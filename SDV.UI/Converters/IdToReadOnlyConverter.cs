using System;
using System.Globalization;
using System.Windows.Data;

namespace SDV.UI.Converters
{
    // Convierte IdEmpleado (int) a booleano para IsReadOnly
    // Si ID > 0 (Editar), devuelve true (Solo Lectura)
    // Si ID = 0 (Nuevo), devuelve false (Editable)
    public class IdToReadOnlyConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is int id)
            {
                // Si el ID es mayor a 0, está editando -> Cédula es SÓLO LECTURA (true)
                return id > 0;
            }
            return false; // Por defecto, editable
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}