import 'package:flutter/material.dart';
import 'package:frontend_app/AlumnoPage/alumnoInicio.dart';
import 'package:frontend_app/Logins/loginImageAlumno.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Logins/loginPasswordAlumno.dart';
import 'network.dart'; // Asegúrate de que esta importación es correcta y que el archivo network.dart tiene las funciones necesarias
import 'dart:math';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  bool _isAdminExpanded = false;
  bool _isStudentExpanded = false;

  late Future<List<dynamic>> futureAlumnos;

  List<String> imagenPerfil = [
    "heroe1.jpg",
    "heroe2.jpg",
    "heroe3.jpg",
    "heroe4.jpg",
    "heroe5.jpg"
  ];

  Color _getColorForAlumno(int alumnoId) {
    // Puedes ajustar la lógica para asignar colores
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple
    ];
    return colors[alumnoId % colors.length];
  }

  @override
  void initState() {
    super.initState();
    futureAlumnos =
        fetchAlumnos(); // Asegúrate de que esta función obtenga los alumnos adecuadamente
  }

  String _getImageForAlumno(int alumnoId) {
    // Usar el ID del alumno para obtener un índice en la lista de imágenes
    return imagenPerfil[alumnoId % imagenPerfil.length];
  }

  Future<void> _loginAdministradores() async {
    final administradores = await fetchAdministradores();
    for (var admin in administradores) {
      if (admin['username'] == _adminUsernameController.text &&
          admin['password'] == _adminPasswordController.text) {
        Navigator.of(context).pushReplacementNamed('/home');
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Credenciales de administrador incorrectas')),
    );
  }

  Future<void> _loginAlumno(dynamic alumno) async {
    if (alumno['Texto'] == 1) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginPasswordAlumno(
          alumno: alumno,
          image: _getImageForAlumno(
              alumno['id']), // Cambiado de alumno.id a alumno['id']
        ),
      ));
    } else if (alumno['Imagen'] == 1) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginImageAlumno(
          alumno: alumno,
          image: _getImageForAlumno(
              alumno['id']), // Cambiado de alumno.id a alumno['id']
        ),
      ));
    }
  }

   Widget _buildStudentLogin() {
    return FutureBuilder<List<dynamic>>(
      future: futureAlumnos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Column(
              children: snapshot.data!.map((alumno) => _buildAlumnoTile(alumno)).toList(),
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildAlumnoTile(dynamic alumno) {
    return Card(
      color: _getColorForAlumno(alumno['id']),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: ClipOval(
          child: Container(
            width: 120,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage("assets/images/${_getImageForAlumno(alumno['id'])}"),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: Text(alumno['nombre'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        onTap: () => _loginAlumno(alumno),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Inicia Sesión',
                  style:
                      GoogleFonts.patrickHand(fontSize: 36, color: Colors.blue),
                ),
              ),
              SizedBox(height: 32.0),
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    if (index == 0) {
                      _isAdminExpanded = !isExpanded;
                    } else {
                      _isStudentExpanded = !isExpanded;
                    }
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) => Text(
                      'Administrador',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.patrickHand(
                          fontSize: 30, color: Colors.black),
                    ),
                    body: Column(
                      children: [
                        TextField(
                          controller: _adminUsernameController,
                          decoration:
                              InputDecoration(labelText: 'Nombre de usuario'),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _adminPasswordController,
                          decoration: InputDecoration(labelText: 'Contraseña'),
                          obscureText: true,
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _loginAdministradores,
                          child: Text('Iniciar sesión'),
                        ),
                      ],
                    ),
                    isExpanded: _isAdminExpanded,
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Alumnos',
                  style:
                      GoogleFonts.patrickHand(fontSize: 36, color: Colors.blue),
                ),
              ),
              SizedBox(height: 12.0),
              _buildStudentLogin(),
            ],
          ),
        ),
      ),
    );
  }
}
