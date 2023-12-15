import 'package:flutter/material.dart';
import 'package:frontend_app/loadingPage.dart';
import 'AdminPage/inicio.dart';
import 'login.dart';
import 'AdminPage/Alumnos/agregarEstudiante.dart';

// Esta es la función principal que se ejecuta cuando se inicia la aplicación.
void main() {
  runApp(MyApp());
}

// La clase MyApp define la estructura principal de la aplicación.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicacion PTVAL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        // Ruta inicial que muestra la página de LoadingPage.
        '/': (context) => LoadingPage(),
        // Ruta '/home' que muestra la página MyHomePage.
        '/home': (context) => MyHomePage(title: 'Pagina de Inicio'),
        // Ruta '/addStudent' que muestra la página AddStudentPage.
        '/addStudent': (context) => AddStudentPage(), 
      },
    );
  }
}
