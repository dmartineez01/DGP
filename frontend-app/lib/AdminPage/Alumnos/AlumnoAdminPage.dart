import 'package:flutter/material.dart';
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
  List<dynamic> tareasAsignadas = [];

  void _fetchAssignedTasks() async {
    try {
      final response =
          await fetchAllAssignedTasksForStudent(widget.alumno['id']);

      print("Todas las tareas son: ");
      print(response);
      setState(() {
        tareasAsignadas = response;
      });
    } catch (error) {
      print('Error al obtener tareas asignadas: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAssignedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alumno['nombre']),
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
              Text('Nombre: ${widget.alumno['nombre']}',
                  style: TextStyle(fontSize: 18)),
              Text('ID: ${widget.alumno['id']}'),
              SizedBox(height: 20),
              Text('Tareas Asignadas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Divider(),
              ListView.separated(
                shrinkWrap: true,
                itemCount: tareasAsignadas.length,
                itemBuilder: (BuildContext context, int index) {
                  final tarea = tareasAsignadas[index];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tarea.entries.map<Widget>((entry) {
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
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Implementa la lógica para editar la información del alumno
                },
                icon: Icon(Icons.edit),
                label: Text('Editar Alumno'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Implementa la lógica para borrar al alumno
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

  void _showAssignTaskDialog() {
    showDialog(
      context: context,
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

                          if (tarea.tipo == 'Fija') {
                            final success = await assignTaskToStudent(
                                widget.alumno['id'], tarea.id, tarea.tipo);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Tarea asignada con éxito')),
                              );
                              _fetchAssignedTasks();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error al asignar la tarea')),
                              );
                            }
                          } else {
                            // La tarea no es de tipo "Fija", navega a la página AjustarCantidadesPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AjustarCantidadesPage(
                                  tareaId: tarea.id,
                                  tipoTarea: tarea.tipo,
                                ),
                              ),
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
