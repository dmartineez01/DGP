import 'package:flutter/material.dart';
import 'package:frontend_app/Modelos/ElementoTarea.dart';
import 'package:frontend_app/Modelos/Tarea.dart';
import 'package:frontend_app/Widgets/menuController.dart';
import 'package:frontend_app/network.dart';

class TareaMaterialAlumnoPage extends StatefulWidget {
  final Tarea tarea;
  final int materialAsignadaId;
  final int alumnoId;

  TareaMaterialAlumnoPage(
      {Key? key,
      required this.tarea,
      required this.materialAsignadaId,
      required this.alumnoId})
      : super(key: key);

  @override
  _TareaMaterialAlumnoPageState createState() =>
      _TareaMaterialAlumnoPageState();
}

class _TareaMaterialAlumnoPageState extends State<TareaMaterialAlumnoPage> {
  late Future<List<ElementoTarea>> futureElementosTarea;
  final PageController _pageController = PageController();
  int currentStep = 1; // Variable para el número de paso actual
  int lastCompletedStep = 0; // Variable para el último paso completado
  bool isTaskCompleted = false;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    futureElementosTarea = fetchElementosTarea(widget.tarea.id);
    _checkTaskCompletion(); // Llama a la nueva función para verificar el estado de completitud
  }

  // Función para verificar el estado de completitud de la tarea
  void _checkTaskCompletion() async {
    try {
      final taskData = await fetchAssignedTask(
          widget.alumnoId, widget.tarea.tipo, widget.materialAsignadaId);
      if (taskData != null && taskData['completada'] != null) {
        setState(() {
          // Convertir el entero a booleano
          isTaskCompleted = taskData['completada'] == 1;
          lastCompletedStep = taskData['ultimo_paso'];
        });
      }
    } catch (e) {
      // Manejar excepciones o errores en la solicitud
      print('Error al obtener el estado de la tarea: $e');
    }
  }

  Future<void> updateElementosTarea() async {
    var nuevosElementos = await fetchElementosTarea(widget.tarea.id);
    setState(() {
      futureElementosTarea = Future.value(nuevosElementos);
    });
  }

  Future<void> _updateTaskStatus(int step) async {
    // Almacenar la página actual antes de la actualización
    currentPageIndex =
        _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;

    // Llamar a la API para actualizar el estado
    final bool success = await updateTaskCompletionStatus(
        widget.alumnoId,
        widget.materialAsignadaId,
        "Material",
        isTaskCompleted,
        step);

    if (success) {
      await updateElementosTarea(); // Actualizar la lista de elementos

      setState(() {
        lastCompletedStep = step;
      });
    } else {
      // Manejar el error
    }
  }

  Widget _buildCompleteButton() {
    // Cambiar texto y color según el estado de completitud
    final String buttonText =
        isTaskCompleted ? 'Marcar como Pendiente' : 'Completar Tarea';
    final Color buttonColor =
        isTaskCompleted ? Colors.red : Colors.green;

    return ElevatedButton(
      onPressed: () async {
        // Llamar a la función de network.dart para actualizar el estado
        final bool success = await updateTaskCompletionStatus(
            widget.alumnoId,
            widget.materialAsignadaId,
            "Material", // Asumiendo que es una tarea de tipo Material
            !isTaskCompleted,
            lastCompletedStep);

        if (success) {
          setState(() {
            // Cambiar el estado de completitud
            isTaskCompleted = !isTaskCompleted;
          });
        } else {
          // Mostrar un mensaje de error o manejar el fallo de alguna manera
        }
      },
      child: Text(buttonText, style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        primary: buttonColor,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      ),
    );
  }

  Widget _buildElementoTareaCard(
      ElementoTarea elemento, int cantidadElemento, int index) {
    bool isStepCompleted = index < lastCompletedStep;
    return Card(
      margin: EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Paso $currentStep", // Muestra el número de paso
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            Semantics(
              label: 'Pictograma de ${elemento.descripcion}', // Asegúrate de reemplazar 'nombre' con la propiedad correcta de ElementoTarea
              child: Image.asset(
                elemento.pictograma,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Descripción: " + elemento.descripcion,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Cantidad a recoger:", // Muestra la cantidad
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "$cantidadElemento", // Muestra la cantidad
              style: TextStyle(fontSize: 60.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => isStepCompleted
                  ? _updateTaskStatus(index)
                  : _updateTaskStatus(index + 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isStepCompleted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank),
                  SizedBox(width: 8), // Espacio entre el icono y el texto
                  Text(isStepCompleted
                      ? 'Marcar como pendiente'
                      : 'Completar Paso'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                primary: isStepCompleted ? Colors.red : Colors.green,
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
            Text(
              "Tarea: " + widget.tarea.nombre,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<ElementoTarea>>(
                future: futureElementosTarea,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      // Asegurarse de que el PageController salte a la página correcta después de reconstruirse
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_pageController.hasClients &&
                            currentPageIndex < snapshot.data!.length) {
                          _pageController.jumpToPage(currentPageIndex);
                        }
                      });

                      return Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                currentStep = index + 1;
                                final elemento = snapshot.data![index];

                                // Obtiene la cantidad del elemento
                                Future<int?> cantidadFuture =
                                    obtenerCantidadElemento(elemento.id);

                                return FutureBuilder<int?>(
                                  future: cantidadFuture,
                                  builder: (context, cantidadSnapshot) {
                                    if (cantidadSnapshot.connectionState ==
                                        ConnectionState.done) {
                                      int? cantidadElemento =
                                          cantidadSnapshot.data;
                                      return _buildElementoTareaCard(
                                          elemento,
                                          cantidadElemento ?? 0,
                                          index);
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                );
                              },
                              onPageChanged: (index) {
                                // Actualizar currentPageIndex cuando la página cambie
                                currentPageIndex = index;
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.grey,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                onPressed: () {
                                  if (_pageController.hasClients &&
                                      _pageController.page! > 0) {
                                    _pageController.previousPage(
                                        duration:
                                            Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                },
                                child:
                                    Icon(Icons.arrow_back, size: 30),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.grey,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                onPressed: () {
                                  if (_pageController.hasClients &&
                                      _pageController.page! <
                                          snapshot.data!.length - 1) {
                                    _pageController.nextPage(
                                        duration:
                                            Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                },
                                child:
                                    Icon(Icons.arrow_forward, size: 30),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildCompleteButton(),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text("Error: ${snapshot.error}"));
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
}
