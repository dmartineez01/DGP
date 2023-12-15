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
  // Controladores para los campos de nombre de usuario y contraseña de administrador
  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  // Estado para controlar la expansión de las secciones de administrador y estudiante
  bool _isAdminExpanded = false;
  bool _isStudentExpanded = false;

  // Futuro para cargar la lista de alumnos
  late Future<List<dynamic>> futureAlumnos;

  // Variables para la paginación de alumnos
  int currentPage = 0;
  final int pageSize = 4;

  // Función para avanzar a la siguiente página de alumnos
  void nextPage() {
    setState(() {
      currentPage++;
    });
  }

  // Función para retroceder a la página anterior de alumnos
  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  // Función para obtener la lista de alumnos para la página actual
  List<dynamic> getAlumnosForCurrentPage(List<dynamic> alumnos) {
    int start = currentPage * pageSize;
    int end = min(alumnos.length, start + pageSize);
    return alumnos.sublist(start, end);
  }

  // Lista de imágenes de perfil
  List<String> imagenPerfil = [
    "heroe1.jpg",
    "heroe2.jpg",
    "heroe3.jpg",
    "heroe4.jpg",
    "heroe5.jpg"
  ];

  // Función para obtener el color de fondo para un alumno específico
  Color _getColorForAlumno(int alumnoId) {
    // Puedes ajustar la lógica para asignar colores
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple
    ];
    return colors[alumnoId % colors.length];
  }

  @override
  void initState() {
    super.initState();
    // Cargar la lista de alumnos al inicio de la página
    futureAlumnos =
        fetchAlumnos(); // Asegúrate de que esta función obtenga los alumnos adecuadamente
  }

  // Función para obtener la imagen de perfil de un alumno
  String _getImageForAlumno(int alumnoId) {
    // Usar el ID del alumno para obtener un índice en la lista de imágenes
    return imagenPerfil[alumnoId % imagenPerfil.length];
  }

  // Función para realizar el inicio de sesión de administradores
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

  // Función para realizar el inicio de sesión de alumnos
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

  // Construir la sección de inicio de sesión de estudiantes
  Widget _buildStudentLogin() {
    return FutureBuilder<List<dynamic>>(
      future: futureAlumnos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            List<dynamic> alumnosPage =
                getAlumnosForCurrentPage(snapshot.data!);
            return Column(
              children: [
                ...alumnosPage
                    .map((alumno) => _buildAlumnoTile(alumno))
                    .toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors
                            .grey, // Color rojo para el botón de retroceso
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12), // Tamaño del botón
                      ),
                      onPressed: previousPage,
                      child:
                          Icon(Icons.arrow_back, size: 30), // Icono más grande
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary:
                            Colors.grey, // Color verde para el botón de avance
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: nextPage,
                      child: Icon(Icons.arrow_forward, size: 30),
                    ),
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
        }
        return CircularProgressIndicator();
      },
    );
  }

  // Construir un elemento de alumno en la lista de inicio de sesión de estudiantes
  Widget _buildAlumnoTile(dynamic alumno) {
    // Verifica si el alumno tiene una imagen de perfil definida
    final tieneImagenPerfil = alumno['imagen_perfil'] != null && alumno['imagen_perfil'].isNotEmpty;

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
                // Usa NetworkImage si hay una URL disponible, de lo contrario usa AssetImage
                image: tieneImagenPerfil 
                    ? AssetImage(alumno['imagen_perfil'])
                    : AssetImage("assets/images/${_getImageForAlumno(alumno['id'])}"),
                fit: BoxFit.contain,
              ),
            ),
            child: Image(
              image: tieneImagenPerfil 
                    ? AssetImage(alumno['imagen_perfil'])
                    : AssetImage("assets/images/${_getImageForAlumno(alumno['id'])}"),
              semanticLabel: 'Imagen de perfil de ${alumno['nombre']}', // Descripción alternativa para accesibilidad
            ),
          ),
        ),
        title: Text(
          alumno['nombre'],
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)
        ),
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
