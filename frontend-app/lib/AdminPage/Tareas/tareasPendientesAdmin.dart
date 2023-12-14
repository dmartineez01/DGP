import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../network.dart';

class TareasPendientesAdminPage extends StatefulWidget {
  @override
  _TareasPendientesAdminPageState createState() =>
      _TareasPendientesAdminPageState();
}

class _TareasPendientesAdminPageState extends State<TareasPendientesAdminPage> {
  List<dynamic> tareasCompletadas = [];
  Map<String, List<dynamic>> tareasPorAlumno = {};

  @override
  void initState() {
    super.initState();
    _fetchCompletedTasks();
  }

 void _fetchCompletedTasks() async {
  try {
    final fetchedTareas = await fetchCompletedTasks();
    _organizarTareasPorAlumno(fetchedTareas);
  } catch (e) {
    print('Error al obtener tareas completadas: $e');
  }
}


  void _organizarTareasPorAlumno(List<dynamic> tareasCompletadas) {
  Map<String, List<dynamic>> tareasPorAlumno = {};
  for (var tarea in tareasCompletadas) {
    String nombreAlumno = tarea['nombre_alumno'] ?? 'Desconocido';
    if (tareasPorAlumno.containsKey(nombreAlumno)) {
      tareasPorAlumno[nombreAlumno]!.add(tarea);
    } else {
      tareasPorAlumno[nombreAlumno] = [tarea];
    }
  }
  setState(() {
    this.tareasPorAlumno = tareasPorAlumno;
  });
}


  Future<void> _confirmTask(int asignadaId, int tareaId, String nombreTarea,
      String tipoTarea, int alumnoId) async {
    try {
      final success = await confirmTask(
          asignadaId, tareaId, alumnoId, nombreTarea, tipoTarea);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarea confirmada con éxito')),
        );
        _fetchCompletedTasks(); // Recargar la lista de tareas
      } else {
        throw Exception('Error al confirmar la tarea');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar la tarea: $e')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  final controller = ZoomDrawer.of(context);
  return Scaffold(
    appBar: AppBar(
      title: Text('Tareas Pendientes'),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          controller?.toggle();
        },
      ),
    ),
    body: tareasPorAlumno.isNotEmpty
        ? ListView(
            children: tareasPorAlumno.entries.map((entry) {
              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4.0,
                child: ExpansionTile(
                  title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                  children: entry.value.map((tarea) {
                    return ListTile(
                      title: Text(tarea['nombre_tarea'] ?? 'Sin nombre'),
                      subtitle: Text(
                        'Tipo: ${tarea['tipo']} - Último Paso: ${tarea['ultimo_paso'] ?? 'No disponible'}'
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _confirmTask(
                          tarea['asignadaId'],
                          tarea['tareaId'],
                          tarea['nombre_tarea'],
                          tarea['tipo'],
                          tarea['alumno_id'],
                        ),
                        child: Text('Confirmar'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          )
        : Center(child: Text("No hay tareas pendientes de confirmar")),
  );
}
}