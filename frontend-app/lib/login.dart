import 'package:flutter/material.dart';
import 'package:frontend_app/AlumnoPage/alumnoInicio.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<String> imageOptions = [
    "contraseña1.jpg",
    "contraseña2.jpg",
    "contraseña3.jpg",
    "contraseña4.jpg"
  ];
  List<int> selectedImages = [];
  List<int> selectedImageIndices = [];

  List<String> imagenPerfil = [
    "heroe1.jpg",
    "heroe2.jpg",
    "heroe3.jpg",
    "heroe4.jpg",
    "heroe5.jpg"
  ];

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
      _showTextLoginDialog(alumno);
    } else if (alumno['Imagen'] == 1) {
      _showImageLoginDialog(alumno);
    }
    // Agrega lógica para 'Audio' si es necesario
  }

  void _showTextLoginDialog(dynamic alumno) {
    TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Inicio de Sesión para ${alumno['nombre']}'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Iniciar Sesión'),
              onPressed: () {
                String enteredPassword = _passwordController.text;
                if (enteredPassword == alumno['password']) {
                  Navigator.of(context).pop();
                  // Agregar un print para depurar la ruta de la imagen
                  // Obtén la ruta de la imagen del alumno
  String imagePath = _getImageForAlumno(alumno['id']);

  // Navega a AlumnoInicioPage con la imagen correcta
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AlumnoInicioPage(
        alumno: alumno,
        image: imagePath,
      ),
    ),
  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña incorrecta')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showImageLoginDialog(dynamic alumno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Utiliza StatefulBuilder para manejar el estado dentro del diálogo
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Seleccione las imágenes en orden'),
              content: Container(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: imageOptions.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          // Asegúrate de llamar a setState dentro del StatefulBuilder
                          if (selectedImageIndices.contains(index)) {
                            selectedImageIndices.remove(index);
                          } else {
                            selectedImageIndices.add(index);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedImageIndices.contains(index)
                                ? Colors.green
                                : Colors.white,
                            width: selectedImageIndices.contains(index) ? 5 : 1,
                          ),
                        ),
                        child: Image.asset(
                            'assets/images/${imageOptions[index]}',
                            fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Confirmar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _checkImageSequence(alumno, selectedImageIndices);
                    selectedImageIndices.clear();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _checkImageSequence(dynamic alumno, List<int> selectedIndices) {
    // Convertir la lista de índices seleccionados en una cadena para comparar
    String selectedSequence = selectedIndices.join(',');

    if (selectedSequence == alumno['password']) {
      // Agregar un print para depurar la ruta de la imagen
      // Obtén la ruta de la imagen del alumno
  String imagePath = _getImageForAlumno(alumno['id']);

  // Navega a AlumnoInicioPage con la imagen correcta
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AlumnoInicioPage(
        alumno: alumno,
        image: imagePath,
      ),
    ),
  );
    } else {
      // Contraseña incorrecta
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Secuencia de imágenes incorrecta')),
      );
    }
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
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) => Text(
                      'Alumnos',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.patrickHand(
                          fontSize: 30, color: Colors.black),
                    ),
                    body: _buildStudentLoginBody(),
                    isExpanded: _isStudentExpanded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentLoginBody() {
    return FutureBuilder<List<dynamic>>(
      future: futureAlumnos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var alumno = snapshot.data![index];
                String imageUrl = _getImageForAlumno(alumno['id']);
                return Card(
                  color: Colors.blue[400],
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: ClipOval(
                      child: Container(
                        width: 90, // Tamaño del contenedor
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage("assets/images/$imageUrl"),
                            fit: BoxFit
                                .contain, // Esto asegura que la imagen se ajuste correctamente
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      alumno['nombre'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    onTap: () => _loginAlumno(alumno),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
        }
        return CircularProgressIndicator();
      },
    );
  }
}
