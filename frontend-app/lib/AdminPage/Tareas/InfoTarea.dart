// Importación de bibliotecas y archivos necesarios.
import 'package:flutter/material.dart';
import '../../Modelos/Tarea.dart';
import '../../Modelos/ElementoTarea.dart';
import '../../network.dart';

// Clase que representa la pantalla de información de una tarea.
class InfoTarea extends StatefulWidget {
  final Tarea tarea;

  InfoTarea({Key? key, required this.tarea}) : super(key: key);

  @override
  _InfoTareaState createState() => _InfoTareaState();
}

class _InfoTareaState extends State<InfoTarea> {
  late Future<List<ElementoTarea>> futureElementosTarea;

  // Inicialización de la pantalla y carga de datos.
  @override
  void initState() {
    super.initState();
    futureElementosTarea = fetchElementosTarea(widget.tarea.id);
  }

  // Construcción de la interfaz de usuario.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de Tarea'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'ID de Tarea: ${widget.tarea.id}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Mostrar los Elementos de la Tarea
              FutureBuilder<List<ElementoTarea>>(
                future: futureElementosTarea,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Column(
                        children: snapshot.data!
                            .map((elemento) => ListTile(
                                  title: Text(elemento.descripcion),
                                  // Aquí puedes añadir más detalles sobre cada ElementoTarea
                                ))
                            .toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                  }
                  return CircularProgressIndicator();
                },
              ),
              SizedBox(height: 20),
              // Botón para eliminar la Tarea
              ElevatedButton(
                onPressed: () async {
                  // Lógica para eliminar la tarea
                  // Dentro de InfoTarea, cuando eliminas la tarea:
                  bool success = await deleteTarea(widget.tarea.id);
                  if (success) {
                    Navigator.of(context).pop(
                        true); // Regresa 'true' para indicar que se necesita una actualización
                  }
                },
                child: Text('Eliminar Tarea'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
