import 'package:flutter/material.dart';
import '../../network.dart';

class EditarAlumnoPage extends StatefulWidget {
  final dynamic alumno;
  final Function(dynamic) onAlumnoUpdated;

  EditarAlumnoPage({Key? key, required this.alumno, required this.onAlumnoUpdated}) : super(key: key);

  @override
  _EditarAlumnoPageState createState() => _EditarAlumnoPageState();
}

class _EditarAlumnoPageState extends State<EditarAlumnoPage> {
  final _nombreController = TextEditingController();
  bool _imagen = false;
  bool _texto = false;
  bool _audio = false;
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.alumno['nombre'];
    _imagen = widget.alumno['Imagen'] == 1;
    _texto = widget.alumno['Texto'] == 1;
    _audio = widget.alumno['Audio'] == 1;
    _passwordController.text = widget.alumno['password'];
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Editar Alumno'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView( // Envuelve tu columna con un SingleChildScrollView
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SwitchListTile(
              title: Text('Imagen'),
              value: _imagen,
              onChanged: (bool value) { setState(() { _imagen = value; }); },
            ),
            SwitchListTile(
              title: Text('Texto'),
              value: _texto,
              onChanged: (bool value) { setState(() { _texto = value; }); },
            ),
            SwitchListTile(
              title: Text('Audio'),
              value: _audio,
              onChanged: (bool value) { setState(() { _audio = value; }); },
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _updateAlumno,
              child: Text('Modificar'),
            ),
          ],
        ),
      ),
    ),
    );
  }

  void _updateAlumno() async {
    bool updated = await updateAlumno(
      widget.alumno['id'],
      _nombreController.text,
      _imagen ? 1 : 0,
      _texto ? 1 : 0,
      _audio ? 1 : 0,
      _passwordController.text,
    );

    if (updated) {
      // Crear un alumno actualizado para enviar de vuelta
      var updatedAlumno = {
        'id': widget.alumno['id'],
        'nombre': _nombreController.text,
        'Imagen': _imagen ? 1 : 0,
        'Texto': _texto ? 1 : 0,
        'Audio': _audio ? 1 : 0,
        'password': _passwordController.text,
      };

      widget.onAlumnoUpdated(updatedAlumno);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alumno actualizado con éxito')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar el alumno')));
    }
  }
}
