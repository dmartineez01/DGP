import 'package:flutter/material.dart';

class TareaMaterialAlumnoPage extends StatelessWidget {
  final dynamic tarea;
  final int? materialAsignadaId;

  TareaMaterialAlumnoPage({Key? key, required this.tarea, this.materialAsignadaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarea Material'),
      ),
      body: Center(
        child: Text('Tarea: ${tarea['nombre']}'),
      ),
    );
  }
}
