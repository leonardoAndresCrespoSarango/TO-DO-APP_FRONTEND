import 'package:flutter/material.dart';
import 'package:front_to_do_app/services/task_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'TaskChartScreen.dart';

/// Pantalla principal que muestra la lista de tareas. Permite agregar, completar y eliminar tareas,
/// así como navegar a la pantalla de estadísticas.
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  /// Instancia del servicio de tareas que maneja las operaciones relacionadas con tareas y estadísticas en tiempo real.
  final TaskService _taskService = TaskService();

  /// Controlador de texto para la entrada de nuevas tareas.
  final TextEditingController _taskController = TextEditingController();

  /// Lista de tareas obtenidas del servidor.
  List<Map<String, dynamic>> _tasks = [];

  /// Indica si la pantalla está en estado de carga.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// Carga las tareas desde el servidor y actualiza el estado de la pantalla.
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    final tasks = await _taskService.fetchTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  /// Agrega una nueva tarea con el título proporcionado y recarga la lista de tareas.
  ///
  /// [title] El título de la nueva tarea.
  Future<void> _addTask(String title) async {
    if (title.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    await _taskService.addTask(title);
    await _loadTasks();

    setState(() {
      _isLoading = false;
      _taskController.clear();
    });
  }

  /// Marca la tarea especificada como completada y recarga la lista de tareas.
  ///
  /// [taskId] El identificador de la tarea a completar.
  Future<void> _completeTask(int taskId) async {
    setState(() {
      _isLoading = true;
    });

    await _taskService.completeTask(taskId);
    await _loadTasks();

    setState(() {
      _isLoading = false;
    });
  }

  /// Elimina lógicamente la tarea especificada y recarga la lista de tareas.
  ///
  /// [taskId] El identificador de la tarea a eliminar.
  Future<void> _deleteTask(int taskId) async {
    setState(() {
      _isLoading = true;
    });

    await _taskService.deleteTask(taskId);
    await _loadTasks();

    setState(() {
      _isLoading = false;
    });
  }

  /// Formatea la fecha de creación de una tarea para mostrarla en formato legible.
  ///
  /// [dateString] La fecha de creación en formato de cadena.
  /// Retorna la fecha formateada como cadena.
  String _formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("My Tasks", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.pie_chart, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskChartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _taskController,
              onSubmitted: (value) => _addTask(value),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.add, color: Colors.grey),
                hintText: "Add a new task",
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
              child: SpinKitPouringHourGlassRefined(
                color: Colors.blue,
                size: 50.0,
              ),
            )
                : ListView.builder(
              itemCount: _tasks.length,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isCompleted = task['isCompleted'];
                final createdAt = _formatDate(task['createdAt']);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      createdAt,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: isCompleted ? Colors.grey : Colors.green,
                          ),
                          onPressed: isCompleted ? null : () => _completeTask(task['id']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
