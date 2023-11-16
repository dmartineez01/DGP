import 'package:flutter/material.dart';
import 'package:frontend_app/AlumnoPage/alumnoInicio.dart';
import 'package:frontend_app/Widgets/menuController.dart';

class LoginPasswordAlumno extends StatelessWidget {
  final dynamic alumno;
  final String image;

  LoginPasswordAlumno({Key? key, required this.alumno, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _passwordController = TextEditingController();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: botonSalir(),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
              child: Text(
                "Por favor, introduce la contraseña",
                style: TextStyle(
                  fontSize: 24, // Tamaño de letra aumentado
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 18), // Tamaño de letra aumentado
                    ),
                  ),
                  SizedBox(height: 40), // Espaciado aumentado
                  ElevatedButton(
                    child: Text(
                      'Iniciar Sesión',
                      style: TextStyle(fontSize: 20), // Tamaño de letra aumentado
                    ),
                    onPressed: () {
                      if (_passwordController.text == alumno['password']) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => AlumnoInicioPage(alumno: alumno, image: image),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contraseña incorrecta')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Botón más grande
                      textStyle: TextStyle(fontSize: 20), // Tamaño de letra aumentado
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
