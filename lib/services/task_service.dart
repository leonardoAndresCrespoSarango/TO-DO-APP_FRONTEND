import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:signalr_netcore/signalr_client.dart';
/// Servicio que maneja las operaciones relacionadas con las tareas.
/// Incluye conexiones HTTP y WebSocket para obtener, agregar,
/// completar y eliminar tareas, así como para actualizar estadísticas en tiempo real.
class TaskService {
  late HubConnection hubConnection;
  //final String apiUrl = "https://penguin-healthy-iguana.ngrok-free.app/api/tasks";
  final String apiUrl = "https://penguin-healthy-iguana.ngrok-free.app/api/tasks";

  /// Constructor que inicia la conexión WebSocket a SignalR.
  TaskService() {
    hubConnection = HubConnectionBuilder()
        .withUrl("https://penguin-healthy-iguana.ngrok-free.app/taskHub")
        .build();
  }

  /// Inicia la conexión con SignalR.
  Future<void> startConnection() async {
    await hubConnection.start();
    print("Connected to SignalR");
  }

  /// Escucha las actualizaciones de estadísticas de tareas en tiempo real.
  /// [onUpdate] es una función de callback que se ejecuta con los datos actualizados.
  void listenForStatisticsUpdates(Function(Map<String, int>) onUpdate) {
    hubConnection.on("ReceiveStatisticsUpdate", (message) {
      final stats = message![0] as Map<String, dynamic>;
      onUpdate({
        'completed': stats['completedTasks'] ?? 0,
        'notCompleted': stats['notCompletedTasks'] ?? 0,
        'deleted': stats['deletedTasks'] ?? 0,
      });
    });
  }

  /// Obtiene una lista de tareas desde el backend.
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List tasks = json.decode(response.body);
      return tasks.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  /// Agrega una nueva tarea con el título proporcionado.
  Future<void> addTask(String title) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"title": title, "isCompleted": false}),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add task");
    }
  }

  /// Marca una tarea como completada.
  Future<void> completeTask(int taskId) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$taskId/complete'),
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to complete task");
    }
  }

  /// Elimina una tarea de forma lógica.
  Future<void> deleteTask(int taskId) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$taskId'),
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to delete task");
    }
  }

  /// Obtiene estadísticas de las tareas (completadas, no completadas, eliminadas).
  Future<Map<String, int>> fetchTaskStatistics() async {
    final response = await http.get(Uri.parse('$apiUrl/statistics'));
    if (response.statusCode == 200) {
      final stats = json.decode(response.body);
      return {
        'completed': stats['completedTasks'] ?? 0,
        'notCompleted': stats['notCompletedTasks'] ?? 0,
        'deleted': stats['deletedTasks'] ?? 0,
      };
    } else {
      throw Exception("Failed to fetch task statistics");
    }
  }
}
