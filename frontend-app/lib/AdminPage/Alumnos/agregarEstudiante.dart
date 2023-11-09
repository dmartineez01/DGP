import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  bool _isImage = true;
  bool _isText = false;
  bool _isAudio = false;

  Future<void> _addStudent() async {
    final studentData = {
      "nombre": _nameController.text,
      "imagen": _isImage ? 1 : 0, // 1 para verdadero, 0 para falso
      "texto": _isText ? 1 : 0,
      "audio": _isAudio ? 1 : 0,
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/alumnos'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(studentData),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alumno añadido exitosamente')),
        );
        Navigator.pop(context);  
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir alumno')),
        );
      }
    } else {
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
