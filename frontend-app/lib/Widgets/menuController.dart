import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:frontend_app/AdminPage/Tareas/TareasPage.dart';
import 'package:frontend_app/AdminPage/Tareas/tareasPendientesAdmin.dart';
import 'package:frontend_app/login.dart';

class MenuScreen extends StatelessWidget {
  final ZoomDrawerController controller;
  final Function(int) onItemTapped;

  // Constructor de MenuScreen
  MenuScreen({required this.controller, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    // Interfaz del menú principal
    return Material(
      color: Colors.blue[800],
      child: Column(
        children: [
          // Encabezado del usuario
          UserAccountsDrawerHeader(
            accountName: Text(
              'Administrador',
              style: TextStyle(fontSize: 20),
            ),
            accountEmail: Text("admin@correo.ugr.es"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/admin-profile.jpg'),
              backgroundColor: Colors.white,
            ),
            decoration: BoxDecoration(color: Colors.blue[700]),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(Icons.admin_panel_settings, 'Administradores', 0),
                _buildMenuItem(Icons.school, 'Alumnos', 1),
                ExpansionTile(
                  leading: Icon(Icons.assignment, color: Colors.white),
                  title: Text('Tareas', style: TextStyle(color: Colors.white)),
                  children: <Widget>[
                    _buildMenuItem(Icons.list, 'Tareas Totales', 2),
                    _buildMenuItem(Icons.hourglass_empty, 'Tareas Pendientes', 3),
                    _buildMenuItem(Icons.flag_sharp, 'Tareas Finalizadas', 4),
                  ],
                ),
                _buildMenuItem(Icons.settings, 'Configuración', 5),
              ],
            ),
          ),
          Divider(
            thickness: 2,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.white),
            title: Text('Salir', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Lógica para salir de la aplicación y volver al LoginPage
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // Función para construir un elemento de menú
  Widget _buildMenuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        onItemTapped(index);
        controller.close!(); // Cierra el menú deslizable
      },
    );
  }
}

class botonSalir extends StatelessWidget {
  final String title;
  final String subtitle;

  // Constructor de botonSalir
  botonSalir({Key? key, this.title = 'Salir', this.subtitle = 'Volver atrás'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(), // Vuelve a la pantalla anterior
      child: Card(
        color: Colors.red[100],
        elevation: 4.0,
        margin: EdgeInsets.all(16.0),
        child: ListTile(
          leading: Icon(Icons.arrow_back, size: 56.0), // Pictograma de salir
          title: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}
