import 'package:flutter/material.dart';

class TareaFijaAlumnoPage extends StatelessWidget {
  final dynamic tarea;
  final int? fijaAsignadaId;

  TareaFijaAlumnoPage({Key? key, required this.tarea, this.fijaAsignadaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarea Fija'),
      ),
      body: Center(
        child: Text('Tarea: ${tarea['nombre']}'),
      ),
    );
  }
}
