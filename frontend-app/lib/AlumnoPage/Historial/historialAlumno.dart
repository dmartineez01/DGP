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

  int _numeroSemana(DateTime fecha) {
    int diaAno = int.parse(DateFormat("D").format(fecha));
    int numeroSemana = ((diaAno - fecha.weekday + 10) / 7).floor();
    return numeroSemana;
  }

  String _rangoSemana(int semana) {
    DateTime ahora = DateTime.now();
    int diferenciaSemana = semana - _numeroSemana(ahora);
    // Cambiar de subtract a add para avanzar semanas
    DateTime lunes =
        ahora.add(Duration(days: -ahora.weekday + 1 + diferenciaSemana * 7));
    DateTime domingo = lunes.add(Duration(days: 6));
    String inicio = DateFormat('dd/MM').format(lunes);
    String fin = DateFormat('dd/MM').format(domingo);
    return "Tareas Completadas: [$inicio - $fin]";
  }

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

                    margin:
                        EdgeInsets.all(8.0), // Margen para separar las tareas
                    child: ListTile(
                      title: Text(
                        tarea['nombre'] ?? 'Sin nombre',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              18, // Tamaño de fuente más grande para el título
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
                              fontSize:
                                  15, // Tamaño de fuente más grande para el subtítulo
                            ),
                          ),
                          Text(
                            'Fecha: $horaFormateada',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  18, // Tamaño de fuente más grande para la hora
                            ),
                          ),
                        ],
                      ),
                      leading: Image.asset(
                        imagenTarea,
                        width: 100, // Tamaño más grande para la imagen
                        height:
                            100, // Ajusta la altura para mantener la proporción
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
      style: ElevatedButton.styleFrom(
        primary: Colors.green, // Color de fondo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Borde redondeado
        ),
      ),
      onPressed: () {
        if (_pageController.hasClients && _pageController.page! > 0) {
          _pageController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min, // Para minimizar el ancho del botón
        children: [
          Icon(Icons.arrow_back, color: Colors.white), // Icono
          Text(" Tareas Anteriores", style: TextStyle(color: Colors.white)), // Texto
        ],
      ),
    ),
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.green, // Color de fondo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Borde redondeado
        ),
      ),
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
        mainAxisSize: MainAxisSize.min, // Para minimizar el ancho del botón
        children: [
          Text("Tareas Siguientes ", style: TextStyle(color: Colors.white)), // Texto
          Icon(Icons.arrow_forward, color: Colors.white), // Icono
        ],
      ),
    ),
  ],
),

      ],
    );
  }

  String _formatoHora(String fechaRaw) {
    try {
      DateTime fecha = DateTime.parse(fechaRaw);
      // Incluyendo el día de la semana y la hora
      return DateFormat('EEEE, HH:mm', 'es_ES')
          .format(fecha); // EEEE es el día de la semana
    } catch (e) {
      return 'Fecha desconocida';
    }
  }

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

  Color _getTareaColor(String tipo) {
    Map<String, Color> colors = {
      'Comanda': Colors.greenAccent,
      'Material': Colors.blueAccent,
      'Fija': Colors.orangeAccent,
    };
    return colors[tipo] ?? Colors.grey; // Color gris como valor por defecto
  }

  String _getTareaImage(String tipo) {
    Map<String, String> tipoImagenes = {
      'Comanda': 'assets/pictogramas/tarea_comanda.png',
      'Material': 'assets/pictogramas/tarea_material.png',
      'Fija': 'assets/pictogramas/tarea_fija.png',
    };
    return tipoImagenes[tipo] ?? 'assets/images/default.png';
  }

  void _ajustarSemanaActual() {
    DateTime ahora = DateTime.now();
    semanaActual = _numeroSemana(ahora);
  }

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
          mainAxisAlignment: MainAxisAlignment.center, // Centrar los elementos horizontalmente
          children: [
            Image.asset(
              'assets/pictogramas/tarea_completada.png', // Reemplaza con la ruta de tu imagen
              width: 120, // Ancho de la imagen
              height: 120, // Alto de la imagen
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
                            height: 20), // Espacio entre el texto y la imagen
                        Image.asset(
                          'assets/pictogramas/no_hay_tareas.png',
                          width: 200, // Ancho de la imagen
                          height: 200, // Alto de la imagen
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
