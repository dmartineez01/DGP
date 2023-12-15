import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../network.dart';

// Clase para la página de administradores.
class AdministradoresPage extends StatefulWidget {
  @override
  _AdministradoresPageState createState() => _AdministradoresPageState();
}

class _AdministradoresPageState extends State<AdministradoresPage> {
  late Future<List<dynamic>> futureAdministradores;
  TextEditingController _searchController = TextEditingController();
  List<dynamic>? _filteredAdministradores;

  @override
  void initState() {
    super.initState();
    // Inicializa la lista de administradores y agrega un listener para el campo de búsqueda.
    futureAdministradores = fetchAdministradores();
    _searchController.addListener(() {
      _filterAdministradores(_searchController.text);
    });
  }

  void _filterAdministradores(String query) {
    if (query.isNotEmpty) {
      futureAdministradores.then((list) {
        setState(() {
          _filteredAdministradores = list
              .where((element) =>
                  element['username'].toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      });
    } else {
      setState(() {
        _filteredAdministradores = null; // Borra la lista filtrada si la consulta está vacía.
      });
    }
  }

  DataRow _createRow(dynamic admin) {
    return DataRow(
      cells: [
        DataCell(Text(admin['username'].toString())),
        DataCell(Text(admin['password'].toString())),
        // Puedes agregar un botón de editar aquí si es necesario.
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ZoomDrawer.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Administradores'),
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
              'Administradores',
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
                    _filterAdministradores('');
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: futureAdministradores,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      var adminsToShow = _filteredAdministradores ?? snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Usuario')),
                              DataColumn(label: Text('Contraseña')),
                              // DataColumn(label: Text('Editar')), // Si necesitas una columna para editar.
                            ],
                            rows: adminsToShow.map((admin) => _createRow(admin)).toList(),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("${snapshot.error}"));
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
