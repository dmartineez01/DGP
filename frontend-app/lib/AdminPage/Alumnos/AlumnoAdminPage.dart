import 'package:flutter/material.dart';
import 'package:frontend_app/AdminPage/Alumnos/editarAlumnoPage.dart';
import '../../network.dart';
import 'AjustarCantidadesPage.dart';
import 'agregarEstudiante.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlumnoAdminPage extends StatefulWidget {
  final dynamic alumno;

  AlumnoAdminPage({Key? key, required this.alumno}) : super(key: key);

  @override
  _AlumnoAdminPageState createState() => _AlumnoAdminPageState();
}

class _AlumnoAdminPageState extends State<AlumnoAdminPage> {
  late dynamic _alumnoData;
  List<dynamic> tareasAsignadas = [];

  @override
  void initState() {
    super.initState();
    _alumnoData = widget.alumno;
    _fetchAssignedTasks();
  }

  void _updateAlumnoData(dynamic updatedAlumno) {
    setState(() {
      _alumnoData = updatedAlumno;
      _fetchAssignedTasks();
    });
  }

  void _fetchAssignedTasks() async {
    try {
      final response =
          await fetchAllAssignedTasksForStudent(widget.alumno['id']);

      setState(() {
        tareasAsignadas = response;
      });
    } catch (error) {
      print('Error al obtener tareas asignadas: $error');
    }
  }

  void _fetchAlumnoData() async {
    try {
      final alumnoData = await fetchAlumno(widget.alumno['id']);
      setState(() {
        _alumnoData = alumnoData;
      });
    } catch (error) {
      print('Error al obtener datos del alumno: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_alumnoData['nombre']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Información del Alumno',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Divider(),
              Text('Nombre: ${_alumnoData['nombre']}',
                  style: TextStyle(fontSize: 18)),
              Text('ID: ${_alumnoData['id']}'),
              SizedBox(height: 20),
              Text('Tareas Asignadas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Divider(),
              Divider(),
              Container(
                height: 250, // Límite de altura para la lista de tareas
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(), // Permite el desplazamiento dentro del ListView
                  itemCount: tareasAsignadas.length,
                  itemBuilder: (BuildContext context, int index) {
                    final tarea = tareasAsignadas[index];
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tarea.entries
          .where((entry) => entry.value != null) // Filtra las entradas que no son null
          .map<Widget>((entry) {
            return Text(
              '${entry.key}: ${entry.value}',
              style: TextStyle(fontSize: 16),
            );
          }).toList(),
      ),
    );
  },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarAlumnoPage(
                        alumno: _alumnoData,
                        onAlumnoUpdated: _updateAlumnoData,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.edit),
                label: Text('Editar Alumno'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  bool? result = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Eliminar Alumno'),
                        content: Text(
                            '¿Estás seguro de que quieres eliminar a este alumno?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancelar'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: Text('Eliminar'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );

                  // Asegurarse de que 'result' no sea 'null' antes de verificar su valor
                  if (result == true) {
                    try {
                      await deleteAlumno(_alumnoData['id']);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Alumno eliminado exitosamente')));
                      Navigator.of(context)
                          .pop(); // Regresar a la pantalla anterior
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error al eliminar el alumno')));
                    }
                  }
                },
                icon: Icon(Icons.delete),
                label: Text('Borrar Alumno'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Muestra el diálogo para asignar una tarea
                  _showAssignTaskDialog();
                },
                icon: Icon(Icons.assignment),
                label: Text('Asignar Tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Resto del código de AlumnoAdminPage)

  void _showAssignTaskDialog() {
    var localContext = context; // Obtener una referencia local al contexto

    showDialog(
      context: localContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Asignar Tarea'),
          content: FutureBuilder<List<dynamic>>(
            future: fetchTareas(),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: snapshot.data!.map((tarea) {
                      return ListTile(
                        title: Text(tarea.nombre),
                        onTap: () async {
                          Navigator.pop(context);

                          final int? assignedTaskId = await assignTaskToStudent(
                              widget.alumno['id'], tarea.id, tarea.tipo);

                          if (assignedTaskId != null) {
                            ScaffoldMessenger.of(localContext).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Tarea asignada con éxito, ID: $assignedTaskId')),
                            );
                            _fetchAssignedTasks();

                            if (tarea.tipo == 'Material') {
                              Navigator.push(
                                localContext, // Usa la referencia local al BuildContext
                                MaterialPageRoute(
                                  builder: (context) => AjustarCantidadesPage(
                                    tareaId: tarea.id,
                                    materialAsignadaId:
                                        assignedTaskId, // Asegúrate de que no sea null
                                  ),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(localContext).showSnackBar(
                              SnackBar(
                                  content: Text('Error al asignar la tarea')),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
