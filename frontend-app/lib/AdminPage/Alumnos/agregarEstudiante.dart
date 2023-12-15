// Importación de bibliotecas necesarias.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importación de funciones relacionadas con la red desde 'network.dart'.
import '../../network.dart';

// Clase que representa la página para añadir un nuevo alumno.
class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  // Clave global para el formulario.
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de nombre y contraseña del alumno.
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // Variables booleanas para determinar qué tipos de contenido puede tener el alumno.
  bool _isImage = true;
  bool _isText = false;
  bool _isAudio = false;

  // Función asincrónica para agregar un nuevo alumno.
  Future<void> _addStudent() async {
    try {
      // Llama a la función 'addStudent' con los datos ingresados.
      bool added = await addStudent(
        _nameController.text,
        _passwordController.text,
        _isImage,
        _isText,
        _isAudio,
      );

      if (added) {
        // Muestra un mensaje de éxito y vuelve a la página anterior.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alumno añadido exitosamente')),
        );
        Navigator.pop(context);
      } else {
        // Muestra un mensaje de error si no se pudo agregar al alumno.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir alumno')),
        );
      }
    } catch (e) {
      // Muestra un mensaje de error si no se pudo conectar con el servidor.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Añadir Alumno")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                validator: (value) =>
                    value!.isEmpty ? 'La contraseña es obligatoria' : null,
              ),
              SwitchListTile(
                title: Text('Imagen'),
                value: _isImage,
                onChanged: (bool value) {
                  setState(() {
                    _isImage = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Texto'),
                value: _isText,
                onChanged: (bool value) {
                  setState(() {
                    _isText = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Audio'),
                value: _isAudio,
                onChanged: (bool value) {
                  setState(() {
                    _isAudio = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Valida el formulario antes de registrar al alumno.
                  if (_formKey.currentState!.validate()) {
                    _addStudent();
                  }
                },
                child: Text('Registrar Alumno'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
