# Sistema de Ventas SDV 🚀

Sistema integral de gestión comercial desarrollado como proyecto para la **Pontificia Universidad Católica del Ecuador (PUCE)**. El sistema integra módulos de talento humano, nómina automatizada y contabilidad con persistencia en la nube.

## 🛠️ Tecnologías y Herramientas
* **Lenguaje:** C# (.NET 8)
* **ORM:** Dapper (Acceso a datos de alto rendimiento)
* **Base de Datos:** MySQL hospedado en **Aiven Cloud** (Servidor Linux)
* **Arquitectura:** N-Capas (UI, DataAccess, Model)
* **Control de Versiones:** Git & GitHub

## ✨ Características Principales
- **Seguridad y Acceso:** Sistema de Login conectado a base de datos remota mediante SSL.
- **Gestión de Empleados:** Administración completa de personal, cargos y departamentos.
- **Módulo de Nómina:** Generación transaccional de roles de pago, incluyendo gestión de bonificaciones y descuentos.
- **Automatización Contable:** Generación automática de asientos contables tras la aprobación de la nómina.
- **Auditoría Interna:** Sistema de logs automático mediante **Triggers** en MySQL para rastrear cambios en tablas críticas (JSON format).

## ⚙️ Configuración del Proyecto
Para ejecutar este sistema, es necesario configurar las credenciales de la base de datos:

1. Clonar el repositorio.
2. Crear un archivo `appsettings.json` en el directorio de salida (o en la raíz del proyecto UI) con el siguiente formato:

```json
{
  "ConnectionStrings": 
  {
    "DefaultConnection": "Server=mysql-2944617e-puce-864.c.aivencloud.com;Port=17843;Database=sistemaventassdv;Uid=avnadmin;Pwd=Aqui_la_contrasenia;SslMode=Required"
  }
}