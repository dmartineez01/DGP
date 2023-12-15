import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_app/Widgets/menuController.dart';
import 'package:frontend_app/network.dart';

class HistorialAlumnoPage extends StatefulWidget {
  final int alumnoId;

  HistorialAlumnoPage({Key? key, required this.alumnoId}) : super(key: key);

  @override
  _HistorialAlumnoPageState createState() => _HistorialAlumnoPageState();
}

class _HistorialAlumnoPageState extends State<HistorialAlumnoPage> {
  List<dynamic> historialTareas = [];
  Map<int, List<dynamic>> tareasPorSemana = {};
  int semanaActual = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  // Función para obtener el historial del alumno
  void _fetchHistorial() async {
    try {
      final fetchedHistorial = await fetchHistorialAlumno(widget.alumnoId);
      setState(() {
        _organizarTareasPorSemana(fetchedHistorial);
        _ajustarSemanaActual();
      });
    } catch (e) {
      print('Error al obtener el historial del alumno: $e');
    }
  }

  // Función para organizar las tareas por semana
  void _organizarTareasPorSemana(List<dynamic> tareas) {
    tareasPorSemana.clear();
    for (var tarea in tareas) {
      DateTime fechaFinalizacion =
          DateTime.parse(tarea['fecha_finalizacion']).toLocal();
      int numeroSemana = _numeroSemana(fechaFinalizacion);
      tareasPorSemana.putIfAbsent(numeroSemana, () => []);
      tareasPorSemana[numeroSemana]!.add(tarea);
    }
  }

  // Función para obtener el número de la semana
  int _numeroSemana(DateTime fecha) {
    int diaAno = int.parse(DateFormat("D").format(fecha));
    int numeroSemana = ((diaAno - fecha.weekday + 10) / 7).floor();
    return numeroSemana;
  }

  // Función para obtener el rango de la semana actual
  String _rangoSemana(int semana) {
    DateTime ahora = DateTime.now();
    int diferenciaSemana = semana - _numeroSemana(ahora);
    DateTime lunes =
        ahora.add(Duration(days: -ahora.weekday + 1 + diferenciaSemana * 7));
    DateTime domingo = lunes.add(Duration(days: 6));
    String inicio = DateFormat('dd/MM').format(lunes);
    String fin = DateFormat('dd/MM').format(domingo);
    return "Tareas Completadas: [$inicio - $fin]";
  }

  // Widget para construir las tareas de la semana
  Widget _buildTareasSemana(List<dynamic> tareasSemana) {
    int numPages = (tareasSemana.length / 2).ceil();
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: numPages,
            itemBuilder: (context, pageIndex) {
              int startIndex = pageIndex * 2;
              int endIndex = startIndex + 2;
              List<dynamic> tareasPagina = tareasSemana.sublist(
                startIndex,
                endIndex > tareasSemana.length ? tareasSemana.length : endIndex,
              );

              return ListView(
                children: tareasPagina.map((tarea) {
                  Color colorTarea = _getTareaColor(tarea['tipo']);
                  String imagenTarea = _getTareaImage(tarea['tipo']);
                  String horaFormateada =
                      _formatoHora(tarea['fecha_finalizacion']);

                  return Container(
                    color: colorTarea.withOpacity(0.2),
                    height: 100,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        tarea['nombre'] ?? 'Sin nombre',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo: ${tarea['tipo']}',
                            style: TextStyle(
                              color: colorTarea,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Fecha: $horaFormateada',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      leading: Image.asset(
                        imagenTarea,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_pageController.hasClients && _pageController.page! > 0) {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, color: Colors.white),
                  Text(" Tareas Anteriores", style: TextStyle(color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(primary: Colors.green),
            ),
            ElevatedButton(
              onPressed: () {
                if (_pageController.hasClients &&
                    _pageController.page! < numPages - 1) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Tareas Siguientes ", style: TextStyle(color: Colors.white)),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
              style: ElevatedButton.styleFrom(primary: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  // Función para formatear la hora de la tarea
  String _formatoHora(String fechaRaw) {
    try {
      DateTime fecha = DateTime.parse(fechaRaw);
      return DateFormat('EEEE, HH:mm', 'es_ES').format(fecha);
    } catch (e) {
      return 'Fecha desconocida';
    }
  }

  // Widget para construir los botones de navegación de semanas
  Widget _buildBotonesNavegacion() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _cambiarSemana(-1),
            child: Row(
                children: [Icon(Icons.arrow_back), Text("Semana Anterior")]),
            style: ElevatedButton.styleFrom(primary: Colors.grey[700]),
          ),
          ElevatedButton(
            onPressed: () => _cambiarSemana(1),
            child: Row(children: [
              Text("Semana Siguiente"),
              Icon(Icons.arrow_forward),
            ]),
            style: ElevatedButton.styleFrom(primary: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Función para obtener el color de la tarea
  Color _getTareaColor(String tipo) {
    Map<String, Color> colors = {
      'Comanda': Colors.greenAccent,
      'Material': Colors.blueAccent,
      'Fija': Colors.orangeAccent,
    };
    return colors[tipo] ?? Colors.grey;
  }

  // Función para obtener la imagen de la tarea
  String _getTareaImage(String tipo) {
    Map<String, String> tipoImagenes = {
      'Comanda': 'assets/pictogramas/tarea_comanda.png',
      'Material': 'assets/pictogramas/tarea_material.png',
      'Fija': 'assets/pictogramas/tarea_fija.png',
    };
    return tipoImagenes[tipo] ?? 'assets/images/default.png';
  }

  // Función para ajustar la semana actual
  void _ajustarSemanaActual() {
    DateTime ahora = DateTime.now();
    semanaActual = _numeroSemana(ahora);
  }

  // Función para cambiar la semana
  void _cambiarSemana(int cambio) {
    setState(() {
      semanaActual += cambio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          botonSalir(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/pictogramas/tarea_completada.png',
                width: 120,
                height: 120,
              ),
              Expanded(
                child: Text(
                  _rangoSemana(semanaActual),
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: tareasPorSemana.containsKey(semanaActual)
                ? _buildTareasSemana(tareasPorSemana[semanaActual]!)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No hay tareas para esta semana",
                            style: TextStyle(fontSize: 20)),
                        SizedBox(
                            height: 20),
                        Image.asset(
                          'assets/pictogramas/no_hay_tareas.png',
                          width: 200,
                          height: 200,
                        ),
                      ],
                    ),
                  ),
          ),
          Divider(
            thickness: 5,
          ),
          _buildBotonesNavegacion(),
        ],
      ),
    );
  }
}
