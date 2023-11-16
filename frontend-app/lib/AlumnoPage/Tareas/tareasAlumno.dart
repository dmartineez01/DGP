import 'package:flutter/material.dart';
import 'package:frontend_app/AlumnoPage/Tareas/Comanda/tareaComandaAlumno.dart';
import 'package:frontend_app/AlumnoPage/Tareas/Fija/tareaFijaAlumno.dart';
import 'package:frontend_app/AlumnoPage/Tareas/Material/tareaMaterialAlumno.dart';
import 'package:frontend_app/Widgets/menuController.dart';
import 'package:frontend_app/network.dart';

class TareasAlumnoPage extends StatefulWidget {
  final int alumnoId; // Agregamos la propiedad para recibir el ID del alumno

  TareasAlumnoPage({Key? key, required this.alumnoId})
      : super(key: key); // Modificamos el constructor para aceptar el ID

  @override
  _TareasAlumnoPageState createState() => _TareasAlumnoPageState();
}

class _TareasAlumnoPageState extends State<TareasAlumnoPage> {
  List<dynamic> tareasAsignadas = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedTasks();
  }

  void _fetchAssignedTasks() async {
    try {
      final response = await fetchAllAssignedTasksForStudent(widget.alumnoId);

      setState(() {
        tareasAsignadas = response;
        print(response);
      });
    } catch (error) {
      print('Error al obtener tareas asignadas: $error');
    }
  }

  Color _getTareaColor(int id) {
    List<Color> colors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
    ];
    return colors[id % colors.length];
  }

  IconData _getTareaIcon(int id) {
    List<IconData> icons = [
      Icons.check_circle_outline,
      Icons.lightbulb_outline,
      Icons.build_circle,
      Icons.explore,
      Icons.star_border,
    ];
    return icons[id % icons.length];
  }

  String _getTareaImage(String tipo) {
    Map<String, String> tipoImagenes = {
      'Comanda': 'assets/pictogramas/tarea_comanda.png',
      'Material': 'assets/pictogramas/tarea_material.png',
      'Fija': 'assets/pictogramas/tarea_fija.png',
    };
    return tipoImagenes[tipo] ?? 'assets/images/default.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          botonSalir(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Mis Tareas',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.separated(
              itemCount: tareasAsignadas.length,
              itemBuilder: (BuildContext context, int index) {
                final tarea = tareasAsignadas[index];
                Color color = _getTareaColor(tarea['id']);
                IconData icono = _getTareaIcon(tarea['id']);
                String imagen = _getTareaImage(tarea['tipo']);

                return Card(
                  color: color.withOpacity(0.3),
                  elevation: 4.0,
                  margin: EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      String tipoTarea = tarea['tipo']; // Tipo de tarea
                      int comandaAsignadaId = tarea['comandaAsignadaId'] ??
                          0; // Si es null, asigna 0
                      int materialAsignadaId = tarea['materialAsignadaId'] ??
                          0; // Si es null, asigna 0
                      int fijaAsignadaId =
                          tarea['fijaAsignadaId'] ?? 0; // Si es null, asigna 0

                      if (tipoTarea == 'Comanda') {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TareaComandaAlumnoPage(
                            tarea: tarea,
                            comandaAsignadaId: comandaAsignadaId,
                          ),
                        ));
                      } else if (tipoTarea == 'Material') {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TareaMaterialAlumnoPage(
                            tarea: tarea,
                            materialAsignadaId: materialAsignadaId,
                          ),
                        ));
                      } else if (tipoTarea == 'Fija') {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TareaFijaAlumnoPage(
                            tarea: tarea,
                            fijaAsignadaId: fijaAsignadaId,
                          ),
                        ));
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(icono, size: 40),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tarea['nombre'],
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Image.asset(imagen, width: 100, height: 100),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10.0); // Espacio entre los elementos
              },
            ),
          ),
        ],
      ),
    );
  }
}
