import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:frontend_app/AdminPage/Alumnos/AlumnoAdminPage.dart';
import '../../network.dart';
import 'agregarEstudiante.dart';

class AlumnosPage extends StatefulWidget {
  @override
  _AlumnosPageState createState() => _AlumnosPageState();
}

class _AlumnosPageState extends State<AlumnosPage> {
  late Future<List<dynamic>> futureAlumnos;
  TextEditingController _searchController = TextEditingController();
  List<dynamic>? _filteredAlumnos;

  @override
  void initState() {
    super.initState();
    futureAlumnos =
        fetchAlumnos(); // Asegúrate de que esta función esté actualizada con la nueva estructura de datos
    _searchController.addListener(() {
      _filterAlumnos(_searchController.text);
    });
  }

  void _filterAlumnos(String query) {
    if (query.isNotEmpty) {
      futureAlumnos.then((list) {
        setState(() {
          _filteredAlumnos = list
              .where((element) =>
                  element['nombre'].toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      });
    } else {
      setState(() {
        _filteredAlumnos =
            null; // Clear the filtered list if the query is empty
      });
    }
  }

  DataRow _createRow(dynamic alumno) {
    return DataRow(
      cells: [
        DataCell(Text(alumno['id'].toString())),
        DataCell(Text(alumno['nombre'].toString())),
        DataCell(Text(alumno['password'].toString())),
        DataCell(Text(alumno['Imagen'] == 1 ? "Sí" : "No")), // Cambiado aquí
        DataCell(Text(alumno['Texto'] == 1 ? "Sí" : "No")), // Cambiado aquí
        DataCell(Text(alumno['Audio'] == 1 ? "Sí" : "No")), // Cambiado aquí
        DataCell(IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => AlumnoAdminPage(alumno: alumno),
              ),
            )
                .then((_) {
              // Recarga los alumnos después de regresar de la página de edición
              setState(() {
                futureAlumnos = fetchAlumnos();
              });
            });
          },
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ZoomDrawer.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Alumnos'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            controller?.toggle();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Alumnos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterAlumnos('');
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: futureAlumnos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      var alumnosToShow = _filteredAlumnos ?? snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis
                            .horizontal, // Desplazamiento horizontal para la tabla
                        child: SingleChildScrollView(
                          child: DataTable(
                            // Desplazamiento vertical para las filas de la tabla
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Contraseña')),
                              DataColumn(label: Text('Imagen')),
                              DataColumn(label: Text('Texto')),
                              DataColumn(label: Text('Audio')),
                              DataColumn(label: Text('Editar')),
                            ],
                            rows: alumnosToShow
                                .map((alumno) => _createRow(alumno))
                                .toList(),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("${snapshot.error}"));
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddStudentPage(),
                  ),
                );
                _searchController.clear();
                setState(() {
                  futureAlumnos = fetchAlumnos();
                  _filteredAlumnos = null;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Alumno'),
            ),
          ],
        ),
      ),
    );
  }
}
