import 'package:flutter/material.dart';
import '../../Modelos/ElementoTarea.dart';
import '../../network.dart';

class AjustarCantidadesPage extends StatefulWidget {
  final int tareaId;

  AjustarCantidadesPage({Key? key, required this.tareaId}) : super(key: key);

  @override
  _AjustarCantidadesPageState createState() => _AjustarCantidadesPageState();
}

class _AjustarCantidadesPageState extends State<AjustarCantidadesPage> {
  Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    // Limpieza de los controladores al salir de la pantalla
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
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
                    () => TextEditingController(text: '1') // Inicializa con 1 por defecto
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
                                final success = await asignarCantidadMaterialElemento(elemento.id, cantidad);
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

  Future<bool> asignarCantidadMaterialElemento(int elementoId, int cantidad) async {
    // Llamada a la API o lógica para guardar la cantidad en el elemento correspondiente
    // Esta función podría enviar las cantidades a tu servidor o base de datos
    print('Guardar cantidad $cantidad para el elemento $elementoId');
    // Simulación de éxito
    return true;
  }
}
