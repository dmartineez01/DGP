// Importación de bibliotecas necesarias.
import 'package:flutter/material.dart';
import 'package:frontend_app/Modelos/ElementoTarea.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importación de funciones relacionadas con la red desde 'network.dart'.
import '../../network.dart';

// Clase que representa la página para ajustar cantidades de elementos de tarea.
class AjustarCantidadesPage extends StatefulWidget {
  final int tareaId;
  final int materialAsignadaId;

  // Constructor que recibe el ID de la tarea y el ID del material asignado.
  AjustarCantidadesPage({
    Key? key,
    required this.tareaId,
    required this.materialAsignadaId,
  }) : super(key: key);

  @override
  _AjustarCantidadesPageState createState() => _AjustarCantidadesPageState();
}

class _AjustarCantidadesPageState extends State<AjustarCantidadesPage> {
  // Mapa de controladores para gestionar las cantidades de los elementos de tarea.
  Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    // Limpieza de los controladores al salir de la pantalla.
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  // Función asincrónica para asignar una cantidad a un elemento de tarea.
  Future<bool> asignarCantidadMaterialElemento(
      int materialAsignadaId, int elementoTareaId, int cantidad) async {
    final url = Uri.parse('http://10.0.2.2:3000/material-elemento');
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "materialAsignada_id": materialAsignadaId,
      "elementoTarea_id": elementoTareaId,
      "cantidad": cantidad,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final success = responseData['success'] as bool;
        return success;
      } else {
        // Maneja los casos de error, por ejemplo, arrojando una excepción o devolviendo false.
        return false;
      }
    } catch (e) {
      // Maneja los errores relacionados con la red, por ejemplo, arrojando una excepción o devolviendo false.
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustar Cantidades'),
      ),
      body: FutureBuilder<List<ElementoTarea>>(
        future: fetchElementosTarea(widget.tareaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var elemento = snapshot.data![index];
                  var controller = _controllers.putIfAbsent(
                    elemento.id,
                    () => TextEditingController(text: '1'), // Inicializa con 1 por defecto.
                  );

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descripción: ${elemento.descripcion}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Cantidad',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  int currentValue = int.tryParse(controller.text) ?? 1;
                                  if (currentValue > 1) {
                                    controller.text = (currentValue - 1).toString();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  int currentValue = int.tryParse(controller.text) ?? 1;
                                  controller.text = (currentValue + 1).toString();
                                },
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              var cantidad = int.tryParse(controller.text);
                              if (cantidad != null) {
                                final success = await asignarCantidadMaterialElemento(
                                    widget.materialAsignadaId, elemento.id, cantidad);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Cantidad guardada con éxito')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al guardar la cantidad')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Cantidad no válida')),
                                );
                              }
                            },
                            child: Text('Guardar Cantidad'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
