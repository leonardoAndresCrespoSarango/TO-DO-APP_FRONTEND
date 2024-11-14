# Documentación de Servicios Externos

## API de Tareas
- **Descripción**: Proporciona endpoints para CRUD de tareas y estadísticas.
- **URL del Servicio**: `http://localhost:5182/api/tasks`
- **Endpoints**:
    - `GET /api/tasks`: Devuelve una lista de tareas no eliminadas.
    - `POST /api/tasks`: Agrega una nueva tarea.
    - `PUT /api/tasks/{id}/complete`: Marca una tarea como completada.
    - `DELETE /api/tasks/{id}`: Elimina una tarea de forma lógica.
    - `GET /api/tasks/statistics`: Devuelve estadísticas de tareas.

- **Ejemplo de Uso en Flutter**: Archivo `services/task_service.dart`.

### WebSocket de Tareas
- **Descripción**: Conexión WebSocket para actualizaciones en tiempo real de las estadísticas de tareas.
- **URL del Servicio**: `http://localhost:5182/taskHub`
- **Configuración en Flutter**:
    - Conectado en `services/task_service.dart`.
    - El método `listenForStatisticsUpdates` escucha eventos para actualizar las estadísticas de tareas en tiempo real.
