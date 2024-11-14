# Documentación de Dependencias

## Dependencias

### flutter
- **Descripción**: Framework principal para el desarrollo de aplicaciones móviles multiplataforma.

### http
- **Versión**: ^1.2.2
- **Propósito**: Realiza peticiones HTTP a la API de tareas.
- **Configuración**: No requiere configuración adicional.

### web_socket_channel
- **Versión**: ^2.0.0
- **Propósito**: Permite la conexión WebSocket para actualizaciones en tiempo real de las tareas.
- **Configuración**: Configurado en `services/task_service.dart`.

### fl_chart
- **Versión**: 0.35.0
- **Propósito**: Generación de gráficos, utilizado para mostrar estadísticas de tareas en `TaskChartScreen`.

### signalr_core y signalr_netcore
- **Versión**: ^1.1.2 y ^0.1.2
- **Propósito**: Facilita la conexión a un servidor SignalR para la transmisión de datos en tiempo real desde el backend.

### provider
- **Versión**: ^6.0.3
- **Propósito**: Gestión del estado en la aplicación.

### intl
- **Versión**: ^0.17.0
- **Propósito**: Formateo de fechas y horas en la interfaz de usuario.

### flutter_spinkit
- **Versión**: ^5.2.1
- **Propósito**: Proporciona animaciones de carga mientras se realizan operaciones asincrónicas.

### flutter_svg
- **Versión**: ^2.0.0
- **Propósito**: Renderización de archivos SVG, utilizada en los íconos del gráfico de pastel.
