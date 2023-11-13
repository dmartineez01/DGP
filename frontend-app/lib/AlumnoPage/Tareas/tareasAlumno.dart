import 'package:flutter/material.dart';
import 'package:frontend_app/network.dart';

class TareasAlumnoPage extends StatefulWidget {
  final int alumnoId; // Agregamos la propiedad para recibir el ID del alumno

  TareasAlumnoPage({Key? key, required this.alumnoId}) : super(key: key); // Modificamos el constructor para aceptar el ID

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
      final response =
          await fetchAllAssignedTasksForStudent(widget.alumnoId);

      setState(() {
        tareasAsignadas = response;
      });
    } catch (error) {
      print('Error al obtener tareas asignadas: $error');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(), // Vuelve a la pantalla anterior
            child: Card(
              elevation: 4.0,
              margin: EdgeInsets.all(16.0),
              child: ListTile(
                leading: Icon(Icons.arrow_back, size: 56.0), // Pictograma de salir
                title: Text(
                  'Salir',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Volver atrás'),
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}
