import 'package:flutter/material.dart';
import 'package:frontend_app/Modelos/ElementoTarea.dart';
import 'package:frontend_app/Widgets/menuController.dart';
import 'package:frontend_app/network.dart';
import 'package:audioplayers/audioplayers.dart';

class AulaComandaAlumnoPage extends StatefulWidget {
  final dynamic tarea;
  final dynamic aula;
  final int comandaAsignadaId;
  final Color aulaColor;
  final IconData aulaIcon;

  AulaComandaAlumnoPage(
      {Key? key,
      required this.tarea,
      required this.aula,
      required this.comandaAsignadaId,
      required this.aulaColor,
      required this.aulaIcon})
      : super(key: key);

  @override
  _AulaComandaAlumnoPageState createState() => _AulaComandaAlumnoPageState();
}

class _AulaComandaAlumnoPageState extends State<AulaComandaAlumnoPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            botonSalir(),
            Card(
              color: widget.aulaColor.withOpacity(0.3), // Color de fondo
              elevation: 4.0,
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(widget.aulaIcon, size: 30), // Ícono del aula
                title: Text(
                  '${widget.tarea['nombre']}: ${widget.aula['nombre']}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<ElementoTarea>>(
                future: fetchElementosTarea(widget.tarea['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return ListView(
                        children: snapshot.data!
                            .map((ElementoTarea elemento) =>
                                _buildElementoTareaCard(
                                    elemento,
                                    widget.aula['id'],
                                    widget.comandaAsignadaId))
                            .toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementoTareaCard(
      ElementoTarea elemento, int aulaId, int comandaAsignada_id) {
    final TextEditingController controller = TextEditingController(text: '1');

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                elemento.pictograma,
                fit: BoxFit.cover,
                height: 80,
                width: 80,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${elemento.descripcion}',
                      style: TextStyle(fontSize: 14.0)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.play_arrow,
                            color: Colors.blue, size: 20),
                        onPressed: () async {
                          String modifiedPath =
                              elemento.sonido.replaceFirst('assets/', '');
                          await _audioPlayer.play(AssetSource(modifiedPath),
                              mode: PlayerMode.lowLatency);
                        },
                      ),
                      Expanded(
                        child: Text(
                          elemento.sonido.split('/').last,
                          style: TextStyle(
                              fontSize: 12.0, fontStyle: FontStyle.italic),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Cantidad',
                            labelStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove, size: 20),
                        onPressed: () {
                          int currentValue = int.tryParse(controller.text) ?? 1;
                          if (currentValue > 1) {
                            controller.text = (currentValue - 1).toString();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: 20),
                        onPressed: () {
                          int currentValue = int.tryParse(controller.text) ?? 1;
                          controller.text = (currentValue + 1).toString();
                        },
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            int cantidad = int.tryParse(controller.text) ?? 1;
                            bool success = await createComandaElemento(
                                comandaAsignada_id,
                                elemento.id,
                                cantidad,
                                aulaId);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Guardado con éxito')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al guardar')));
                            }
                          },
                          child:
                              Text('Guardar', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
