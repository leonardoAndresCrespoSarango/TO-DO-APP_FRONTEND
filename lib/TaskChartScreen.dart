import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:front_to_do_app/services/task_service.dart';

/// Pantalla que muestra las estadísticas de tareas en un gráfico de pastel.
/// Las estadísticas incluyen el número de tareas completadas, no completadas y eliminadas.
class TaskChartScreen extends StatefulWidget {
  @override
  _TaskChartScreenState createState() => _TaskChartScreenState();
}

class _TaskChartScreenState extends State<TaskChartScreen> {
  /// Instancia del servicio de tareas para obtener estadísticas y escuchar actualizaciones en tiempo real.
  final TaskService _taskService = TaskService();

  /// Número de tareas completadas.
  int completedTasks = 0;

  /// Número de tareas no completadas.
  int notCompletedTasks = 0;

  /// Número de tareas eliminadas.
  int deletedTasks = 0;

  /// Indica si la pantalla está en estado de carga.
  bool isLoading = true;

  /// Índice de la sección del gráfico actualmente seleccionada.
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadTaskStatistics();
    _taskService.startConnection().then((_) {
      _taskService.listenForStatisticsUpdates((stats) {
        setState(() {
          completedTasks = stats['completed'] ?? 0;
          notCompletedTasks = stats['notCompleted'] ?? 0;
          deletedTasks = stats['deleted'] ?? 0;
          isLoading = false;
        });
      });
    });
  }

  /// Carga las estadísticas de tareas desde el servidor y actualiza el estado.
  Future<void> _loadTaskStatistics() async {
    final stats = await _taskService.fetchTaskStatistics();
    setState(() {
      completedTasks = stats['completed'] ?? 0;
      notCompletedTasks = stats['notCompleted'] ?? 0;
      deletedTasks = stats['deleted'] ?? 0;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Estadísticas de Tareas"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(
        child: SpinKitHourGlass(
          color: Colors.teal,
          size: 50.0,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1.2,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _buildLegend(),
            ),
          ],
        ),
      ),
    );
  }

  /// Genera las secciones del gráfico de pastel para mostrar las estadísticas de tareas.
  /// Cada sección representa una categoría de tareas (completadas, no completadas, eliminadas).
  List<PieChartSectionData> showingSections() {
    final List<double> taskValues = [
      completedTasks.toDouble(),
      notCompletedTasks.toDouble(),
      deletedTasks.toDouble()
    ];
    final List<Color> taskColors = [Colors.green, Colors.blue, Colors.red];
    final List<String> titles = ['Completadas', 'No Completadas', 'Eliminadas'];
    final List<String> svgPaths = [
      'lib/assets/icons/completed.svg',
      'lib/assets/icons/not_completed.svg',
      'lib/assets/icons/delete.svg'
    ];

    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 20.0 : 16.0;
      final double radius = isTouched ? 110.0 : 100.0;
      final double widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: taskColors[i],
        value: taskValues[i],
        title: '${taskValues[i].toInt()}', // Muestra el valor exacto sin porcentaje
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
        badgeWidget: _Badge(
          svgPaths[i],
          size: widgetSize,
          borderColor: Colors.black,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }


  /// Construye la leyenda para el gráfico de pastel, que muestra los colores y títulos
  /// correspondientes a cada categoría de tareas (completadas, no completadas, eliminadas).
  Widget _buildLegend() {
    final List<Color> taskColors = [Colors.green, Colors.blue, Colors.red];
    final List<String> titles = ['Completadas', 'No Completadas', 'Eliminadas'];
    final List<int> counts = [completedTasks, notCompletedTasks, deletedTasks];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: taskColors[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${titles[index]}: ${counts[index]}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Widget personalizado que representa un icono en el gráfico de pastel.
/// Este widget se utiliza como un indicador visual para cada sección del gráfico.
class _Badge extends StatelessWidget {
  /// Ruta del archivo SVG que representa el icono.
  final String svgAsset;

  /// Tamaño del icono.
  final double size;

  /// Color del borde del icono.
  final Color borderColor;

  /// Constructor para inicializar los valores del icono [_Badge].
  const _Badge(this.svgAsset, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Center(
        child: SvgPicture.asset(svgAsset),
      ),
    );
  }
}
