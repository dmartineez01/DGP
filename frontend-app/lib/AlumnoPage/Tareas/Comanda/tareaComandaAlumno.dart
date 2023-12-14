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
  bool isTaskCompleted =
      false; // Añade esta variable para el estado de completitud

  @override
  void initState() {
    super.initState();
    _fetchAulas();
    _checkTaskCompletion(); // Llama a la función para verificar el estado de completitud
  }

  void _checkTaskCompletion() async {
    try {
      final taskData = await fetchAssignedTask(
          widget.alumnoId, widget.tarea['tipo'], widget.comandaAsignadaId);
      if (taskData != null && taskData['completada'] != null) {
        setState(() {
          isTaskCompleted = taskData['completada'] ==
              1; // Asume que 'completada' es un entero
        });
      }
    } catch (e) {
      print('Error al obtener el estado de la tarea: $e');
    }
  }

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
          botonSalir(),
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
            label:
                'Imagen representativa de un aula', // Descripción adecuada de la imagen
            child: Image.asset(
              'assets/pictogramas/aula.png', // Asegúrate de tener esta imagen en tus assets
              width: 400,
              height: 150,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: aulas.length,
              itemBuilder: (context, index) {
                final aula = aulas[index];
                Color aulaColor = _getAulaColor(aula[
                    'id']); // Función para obtener un color basado en el ID
                IconData aulaIcon = _getAulaIcon(aula[
                    'id']); // Función para obtener un ícono basado en el tipo de aula

                return Card(
                  color: aulaColor.withOpacity(0.3), // Color de fondo
                  elevation: 4.0,
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(aulaIcon, size: 30), // Ícono del aula
                    title: Text(
                      aula['nombre'],
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
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
          _buildCompleteButton()
        ],
      ),
    );
  }

  Color _getAulaColor(int id) {
    // Esta función devuelve un color basado en el ID del aula
    // Por ejemplo, puedes asignar colores específicos a IDs específicos
    // o usar una lógica para generar colores de manera más dinámica
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
    ];
    // Esto asignará un color de la lista de forma cíclica basada en el ID
    return colors[id % colors.length];
  }

  IconData _getAulaIcon(int id) {
    // Esta función devuelve un ícono basado en el tipo de aula
    // La lógica puede variar dependiendo de cómo identifiques los tipos de aula
    // Por ejemplo, puedes usar un switch o una serie de condicionales
    // Aquí se da un ejemplo simple con algunos íconos comunes
    List<IconData> icons = [
      Icons.school,
      Icons.science,
      Icons.sports_basketball,
      Icons.music_note,
      Icons.computer,
      Icons.local_library,
    ];
    // Esto asignará un ícono de la lista de forma cíclica basada en el ID
    return icons[id % icons.length];
  }
}
