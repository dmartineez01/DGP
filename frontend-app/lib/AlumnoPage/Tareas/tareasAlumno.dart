import 'package:flutter/material.dart';
import 'package:frontend_app/AlumnoPage/Tareas/Comanda/tareaComandaAlumno.dart';
import 'package:frontend_app/AlumnoPage/Tareas/Fija/tareaFijaAlumno.dart';
import 'package:frontend_app/AlumnoPage/Tareas/Material/tareaMaterialAlumno.dart';
import 'package:frontend_app/Modelos/ElementoTarea.dart';
import 'package:frontend_app/Modelos/Tarea.dart';
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
  Map<int, List<ElementoTarea>> elementosTareas =
      {}; // Nuevo mapa para almacenar los elementos de cada tarea
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchAssignedTasks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _fetchAssignedTasks() async {
    try {
      final response = await fetchAllAssignedTasksForStudent(widget.alumnoId);
      setState(() {
        tareasAsignadas = response;
        print(response);
      });
      _fetchElementosTareas();
    } catch (error) {
      print('Error al obtener tareas asignadas: $error');
    }
  }

  void _fetchElementosTareas() async {
    try {
      for (var tarea in tareasAsignadas) {
        final elementos = await fetchElementosTarea(tarea['id']);
        setState(() {
          elementosTareas[tarea['id']] = elementos;
        });
      }
    } catch (error) {
      print('Error al obtener elementos de la tarea: $error');
    }
  }

  Color _getTareaColor(String tipo) {
    Map<String, Color> colors = {
      'Comanda': Colors.greenAccent,
      'Material': Colors.blueAccent,
      'Fija': Colors.orangeAccent,
    };
    return colors[tipo] ?? Colors.grey; // Color gris como valor por defecto
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
            child: Column(
              children: <Widget>[
                // Imagen del pictograma
                Semantics(
                  label:
                      'Imagen representativa de mis tareas', // Descripción específica de la tarea
                  child: Image.asset('assets/pictogramas/mis_tareas.png',
                      width: 100, height: 100),
                ),

                SizedBox(width: 10), // Espacio entre la imagen y el texto
                // Texto del título
                Text(
                  'Mis Tareas',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: (tareasAsignadas.length / 2)
                  .ceil(), // Calcula el número de páginas
              itemBuilder: (BuildContext context, int pageIndex) {
                int startIndex = pageIndex * 2;
                int endIndex = startIndex + 2;
                endIndex = endIndex > tareasAsignadas.length
                    ? tareasAsignadas.length
                    : endIndex;

                return Column(
                  children: tareasAsignadas
                      .getRange(startIndex, endIndex)
                      .map((tarea) {
                    Color color = _getTareaColor(tarea['tipo']);
                    IconData icono = _getTareaIcon(tarea['id']);
                    print(elementosTareas);
                    String imagen;
                    if (elementosTareas[tarea['id']] != null &&
                        elementosTareas[tarea['id']]!.isNotEmpty) {
                      imagen = elementosTareas[tarea['id']]!.first.pictograma;
                    } else {
                      imagen = _getTareaImage(tarea['tipo']);
                    }

                    return Card(
                      color: color.withOpacity(0.3),
                      elevation: 4.0,
                      margin: EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          String tipoTarea = tarea['tipo']; // Tipo de tarea
                          int comandaAsignadaId = tarea['comandaAsignadaId'] ??
                              0; // Si es null, asigna 0
                          int materialAsignadaId =
                              tarea['materialAsignadaId'] ??
                                  0; // Si es null, asigna 0
                          int fijaAsignadaId = tarea['fijaAsignadaId'] ??
                              0; // Si es null, asigna 0

                          if (tipoTarea == 'Comanda') {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TareaComandaAlumnoPage(
                                tarea: tarea,
                                comandaAsignadaId: comandaAsignadaId,
                                alumnoId: widget.alumnoId,
                              ),
                            ));
                          } else if (tipoTarea == 'Material') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TareaMaterialAlumnoPage(
                                  tarea: Tarea.fromMap(tarea as Map<String,
                                      dynamic>), // Conversión aquí
                                  materialAsignadaId: materialAsignadaId,
                                  alumnoId: widget.alumnoId,
                                ),
                              ),
                            );
                          } else if (tipoTarea == 'Fija') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TareaFijaAlumnoPage(
                                  tarea: Tarea.fromMap(tarea as Map<String,
                                      dynamic>), // Conversión aquí
                                  fijaAsignadaId: fijaAsignadaId,
                                  alumnoId: widget.alumnoId,
                                ),
                              ),
                            );
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Semantics(
                                label:
                                    'Imagen representativa de la tarea ${tarea['nombre']}', // Descripción específica de la tarea
                                child: Image.asset(imagen,
                                    width: 100, height: 100),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: 20.0), // Añade un espacio en la parte inferior
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary:
                        Colors.grey, // Color rojo para el botón de retroceso
                    padding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12), // Tamaño del botón
                  ),
                  onPressed: () {
                    if (_pageController.hasClients &&
                        _pageController.page! > 0) {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Icon(Icons.arrow_back, size: 30), // Icono más grande
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey, // Color verde para el botón de avance
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    if (_pageController.hasClients &&
                        _pageController.page! < (tareasAsignadas.length - 1)) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Icon(Icons.arrow_forward, size: 30),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
