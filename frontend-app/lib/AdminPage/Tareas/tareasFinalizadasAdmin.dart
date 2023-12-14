import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:intl/intl.dart';
import '../../network.dart';

class TareasFinalizadasAdminPage extends StatefulWidget {
  @override
  _TareasFinalizadasAdminPageState createState() =>
      _TareasFinalizadasAdminPageState();
}

class _TareasFinalizadasAdminPageState
    extends State<TareasFinalizadasAdminPage> {
  List<dynamic> tareasFinalizadas = [];
  Map<String, List<dynamic>> tareasPorAlumno = {};

  void _organizarTareasPorAlumno(List<dynamic> tareasFinalizadas) {
    tareasPorAlumno.clear();
    for (var tarea in tareasFinalizadas) {
      String nombreAlumno = tarea['nombre_alumno'] ?? 'Desconocido';
      if (tareasPorAlumno.containsKey(nombreAlumno)) {
        tareasPorAlumno[nombreAlumno]!.add(tarea);
      } else {
        tareasPorAlumno[nombreAlumno] = [tarea];
      }
    }
  }

  String _formatDate(String? rawDate) {
  if (rawDate == null) return 'Desconocida';
  try {
    final date = DateTime.parse(rawDate);
    return DateFormat('dd/MM/yyyy HH:mm').format(date); // Incluir fecha y hora
  } catch (e) {
    return 'Formato inválido';
  }
}

  
  @override
  void initState() {
    super.initState();
    _fetchFinalizedTasks();
  }

  void _fetchFinalizedTasks() async {
    try {
      final fetchedTareas = await fetchFinalizedTasks();
      setState(() {
        _organizarTareasPorAlumno(fetchedTareas);
      });
    } catch (e) {
      print('Error al obtener tareas finalizadas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ZoomDrawer.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas Finalizadas'),
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
                    leading: Icon(Icons.school), // Icono representativo
                    title: Text(
                      entry.key,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((tarea) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: ListTile(
                          leading: _getIconForTaskType(tarea['tipo']),
                          title: Text(
                            tarea['nombre'] ?? 'Sin nombre',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
          'Fecha finalización: ${_formatDate(tarea['fecha_finalizacion'])}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            )
          : Center(child: Text("No hay tareas finalizadas")),
    );
  }

  Icon _getIconForTaskType(String? tipo) {
    switch (tipo) {
      case 'Comanda':
        return Icon(Icons.list_alt, color: Colors.blue);
      case 'Material':
        return Icon(Icons.build_circle, color: Colors.green);
      case 'Fija':
        return Icon(Icons.event_note, color: Colors.orange);
      default:
        return Icon(Icons.task_alt, color: Colors.grey);
    }
  }
}