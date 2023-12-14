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
  final PageController _pageController = PageController();
  List<ElementoTarea> elementosTarea = [];
  Map<int, TextEditingController> cantidadControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchElementosTarea();
  }

  void _fetchElementosTarea() async {
    try {
      elementosTarea = await fetchElementosTarea(widget.tarea['id']);
      setState(() {
        for (var elemento in elementosTarea) {
          cantidadControllers[elemento.id] = TextEditingController(text: '1');
        }
      });
    } catch (e) {
      // Manejar excepción
    }
  }

  Widget _buildElementoTareaCard(ElementoTarea elemento) {
    return Card(
      margin: EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen
             Semantics(
          label: 'Pictograma de ${elemento.descripcion}', // Asegúrate de reemplazar 'nombre' con la propiedad correcta de ElementoTarea
          child: Image.asset(
            elemento.pictograma,
            fit: BoxFit.contain,
            width: double.infinity,
            height: 150,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
          ),
        ),
            SizedBox(height: 10),
            // Descripción
            Text(
              "Descripcion: " + elemento.descripcion,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Controles de Cantidad
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    int currentValue =
                        int.tryParse(cantidadControllers[elemento.id]!.text) ??
                            1;
                    if (currentValue > 1) {
                      cantidadControllers[elemento.id]!.text =
                          (currentValue - 1).toString();
                    }
                  },
                  child: CircleAvatar(
                    radius:
                        24, // Ajusta el radio para cambiar el tamaño del círculo
                    backgroundColor: Colors.red, // Fondo rojo
                    child: Icon(Icons.remove, size: 40, color: Colors.white),
                  ),
                ),
                Container(
                  width: 60,
                  child: TextField(
                    controller: cantidadControllers[elemento.id],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                  ),
                ),
                InkWell(
                  onTap: () {
                    int currentValue =
                        int.tryParse(cantidadControllers[elemento.id]!.text) ??
                            1;
                    cantidadControllers[elemento.id]!.text =
                        (currentValue + 1).toString();
                  },
                  child: CircleAvatar(
                    radius:
                        24, // Ajusta el radio para cambiar el tamaño del círculo
                    backgroundColor: Colors.green, // Fondo rojo
                    child: Icon(Icons.add, size: 40, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Botón Guardar
            ElevatedButton(
              onPressed: () {
                // Lógica para guardar la tarea
              },
              child: Text('Guardar', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            Expanded(
              child: elementosTarea.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: elementosTarea.length,
                      itemBuilder: (context, index) {
                        return _buildElementoTareaCard(elementosTarea[index]);
                      },
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
            // Botones de Navegación

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary:
                          Colors.grey, // Color rojo para el botón de retroceso
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12), // Tamaño del botón
                    ),
                    onPressed: () {
                      if (_pageController.hasClients &&
                          _pageController.page! > 0) {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Icon(Icons.arrow_back, size: 30), // Icono más grande
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary:
                          Colors.grey, // Color verde para el botón de avance
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      if (_pageController.hasClients &&
                          _pageController.page! < (elementosTarea.length - 1)) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Icon(Icons.arrow_forward, size: 30),
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
