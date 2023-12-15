import 'package:flutter/material.dart';
import 'package:frontend_app/AlumnoPage/Tareas/Comanda/aulaComandaAlumno.dart';
import 'package:frontend_app/Widgets/menuController.dart';
import 'package:frontend_app/network.dart';

class TareaComandaAlumnoPage extends StatefulWidget {
  final dynamic tarea;
  final int comandaAsignadaId;
  final int alumnoId;

  TareaComandaAlumnoPage({
    Key? key,
    required this.tarea,
    required this.comandaAsignadaId,
    required this.alumnoId,
  }) : super(key: key);

  @override
  _TareaComandaAlumnoPageState createState() => _TareaComandaAlumnoPageState();
}

class _TareaComandaAlumnoPageState extends State<TareaComandaAlumnoPage> {
  List<dynamic> aulas = [];
  bool isTaskCompleted = false;

  @override
  void initState() {
    super.initState();
    _fetchAulas();
    _checkTaskCompletion(); // Verificar el estado de completitud
  }

  // Función para verificar el estado de completitud de la tarea
  void _checkTaskCompletion() async {
    try {
      final taskData = await fetchAssignedTask(
          widget.alumnoId, widget.tarea['tipo'], widget.comandaAsignadaId);
      if (taskData != null && taskData['completada'] != null) {
        setState(() {
          isTaskCompleted = taskData['completada'] == 1; // Convertir a booleano
        });
      }
    } catch (e) {
      print('Error al obtener el estado de la tarea: $e');
    }
  }

  // Función para obtener la lista de aulas
  void _fetchAulas() async {
    try {
      final fetchedAulas = await fetchAulas();
      setState(() {
        aulas = fetchedAulas;
      });
    } catch (e) {
      print('Error al obtener aulas: $e');
    }
  }

  // Widget para el botón de completar la tarea
  Widget _buildCompleteButton() {
    final String buttonText =
        isTaskCompleted ? 'Marcar como Pendiente' : 'Completar Tarea';
    final Color buttonColor = isTaskCompleted ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () async {
          final bool success = await updateTaskCompletionStatus(widget.alumnoId,
              widget.comandaAsignadaId, "Comanda", !isTaskCompleted, 0);

          if (success) {
            setState(() {
              isTaskCompleted = !isTaskCompleted;
            });
          } else {
            // Manejar el fallo de alguna manera
          }
        },
        child: Text(buttonText, style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          primary: buttonColor,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          botonSalir(), // Widget para salir de la página
          Text(
            "Tarea: " + widget.tarea["nombre"],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Aulas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Semantics(
            label: 'Imagen representativa de un aula', // Descripción de la imagen
            child: Image.asset(
              'assets/pictogramas/aula.png', // Ruta de la imagen
              width: 400,
              height: 150,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: aulas.length,
              itemBuilder: (context, index) {
                final aula = aulas[index];
                Color aulaColor = _getAulaColor(aula['id']); // Obtener color del aula
                IconData aulaIcon = _getAulaIcon(aula['id']); // Obtener ícono del aula

                return Card(
                  color: aulaColor.withOpacity(0.3),
                  elevation: 4.0,
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(aulaIcon, size: 30),
                    title: Text(
                      aula['nombre'],
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Navegar a la página del aula
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AulaComandaAlumnoPage(
                            tarea: widget.tarea,
                            aula: aula,
                            comandaAsignadaId: widget.comandaAsignadaId,
                            aulaColor: aulaColor,
                            aulaIcon: aulaIcon),
                      ));
                    },
                  ),
                );
              },
            ),
          ),
          _buildCompleteButton() // Widget del botón de completar la tarea
        ],
      ),
    );
  }

  // Función para obtener un color basado en el ID del aula
  Color _getAulaColor(int id) {
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
    ];
    return colors[id % colors.length];
  }

  // Función para obtener un ícono basado en el tipo de aula
  IconData _getAulaIcon(int id) {
    List<IconData> icons = [
      Icons.school,
      Icons.science,
      Icons.sports_basketball,
      Icons.music_note,
      Icons.computer,
      Icons.local_library,
    ];
    return icons[id % icons.length];
  }
}
