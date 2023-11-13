import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../network.dart';

class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isImage = true;
  bool _isText = false;
  bool _isAudio = false;

  Future<void> _addStudent() async {
    try {
    bool added = await addStudent(
      _nameController.text,
      _passwordController.text,
      _isImage, 
      _isText,
      _isAudio,
    );

      if (added) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alumno añadido exitosamente')),
        );
        Navigator.pop(context);  
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir alumno')),
        );
      }
    } catch (e) {
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
                validator: (value) => value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                validator: (value) => value!.isEmpty ? 'La contraseña es obligatoria' : null,
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
