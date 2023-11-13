import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:frontend_app/login.dart';

class MenuScreen extends StatelessWidget {
  final ZoomDrawerController controller;
  final Function(int) onItemTapped;

  MenuScreen({required this.controller, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue[800],
      child: Column(
        children: [
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
                _buildMenuItem(
                    Icons.admin_panel_settings, 'Administradores', 0),
                _buildMenuItem(Icons.school, 'Alumnos', 1),
                _buildMenuItem(Icons.assignment, 'Tareas', 2),
                _buildMenuItem(Icons.settings, 'Configuración', 3),
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

  Widget _buildMenuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        onItemTapped(index);
        controller.close!();
      },
    );
  }
}
