import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_app/AdminPage/Tareas/selectImage.dart';
import '../../Modelos/ElementoTarea.dart';
import '../../Modelos/Tarea.dart';
import '../../network.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/src/source.dart';

import 'package:http/http.dart' as http;

// Clase que representa la página para agregar una nueva tarea.
class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _taskFormKey = GlobalKey<FormState>();
  String _taskName = "";
  String _selectedTaskType = "Fija";
  List<ElementoTarea> _taskElements = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _taskNameController = TextEditingController();

  // Función para construir la interfaz de usuario de la página.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Añadir Tarea"),
      ),
      body: Form(
        key: _taskFormKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _taskNameController,
              decoration: InputDecoration(labelText: 'Nombre de la tarea'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduce un nombre';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              hint: Text("Selecciona un tipo"),
              value: _selectedTaskType,
              items: [
                DropdownMenuItem(value: "Fija", child: Text("Fija")),
                DropdownMenuItem(value: "Comanda", child: Text("Comanda")),
                DropdownMenuItem(value: "Material", child: Text("Material")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTaskType = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecciona un tipo';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addElement,
              child: Text("Añadir ElementoTarea"),
            ),
            SizedBox(height: 20),
            ..._taskElements
                .map((e) => Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Imagen',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            child: Image.asset(
                              e.pictograma,
                              fit: BoxFit.contain,
                              height: 200,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Descripción',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  e.descripcion,
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Sonido',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e.sonido.split('/').last,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.play_arrow,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String modifiedPath = e.sonido
                                            .replaceFirst('assets/', '');
                                        await _audioPlayer.play(
                                            AssetSource(modifiedPath),
                                            mode: PlayerMode.lowLatency);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTask,
              child: Text("Guardar Tarea"),
            ),
          ],
        ),
      ),
    );
  }

  // Función para mostrar un diálogo y añadir un ElementoTarea.
  void _addElement() async {
    var element = await showDialog<ElementoTarea>(
        context: context,
        builder: (context) => SingleChildScrollView(
              child: AddElementDialog(),
            ));

    if (element != null) {
      setState(() {
        _taskElements.add(element);
      });
    }
  }

  // Función para añadir una nueva tarea y sus elementos.
  void _addTask() async {
    if (_taskFormKey.currentState!.validate()) {
      try {
        Tarea newTask = await addTarea(_taskNameController.text, _selectedTaskType);

        for (var element in _taskElements) {
          await addElementoTarea(element.pictograma, element.descripcion, element.sonido, element.video, newTask.id);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarea añadida exitosamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// Diálogo para agregar un elemento de tarea.
class AddElementDialog extends StatefulWidget {
  @override
  _AddElementDialogState createState() => _AddElementDialogState();
}

class _AddElementDialogState extends State<AddElementDialog> {
  final _formKey = GlobalKey<FormState>();
  String _pictograma = "";
  String _descripcion = "";
  String _sonido = "";
  String? _selectedImage;
  AudioPlayer _audioPlayer = AudioPlayer();

  // Función para construir la interfaz de usuario del diálogo.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Añadir ElementoTarea"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Descripción'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce una descripción';
                }
                _descripcion = value;
                return null;
              },
            ),
            _selectedImage == null
                ? ElevatedButton(
                    onPressed: _selectImage,
                    child: Text("Seleccionar imagen"),
                  )
                : Container(
                    width: 100.0,
                    height: 100.0,
                    child: Image.asset(
                      _selectedImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
            ElevatedButton(
              onPressed: _selectAudio,
              child: Text("Seleccionar sonido"),
            ),
            _sonido.isEmpty
                ? Container()
                : Column(
                    children: [
                      Text(_sonido.split('/').last),
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () async {
                          String modifiedPath =
                              _sonido.replaceFirst('assets/', '');
                          await _audioPlayer.play(AssetSource(modifiedPath),
                              mode: PlayerMode.lowLatency);
                        },
                      ),
                    ],
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addElement,
              child: Text("Añadir"),
            ),
          ],
        ),
      ),
    );
  }

  // Función para añadir un nuevo elemento de tarea.
  void _addElement() {
    if (_formKey.currentState!.validate()) {
      var element = ElementoTarea(
        id: 0, // Este ID será reemplazado cuando se guarde en el servidor
        pictograma: _selectedImage!,
        descripcion: _descripcion,
        sonido: _sonido,
      );

      Navigator.of(context).pop(element);
    }
  }

  // Función para seleccionar una imagen.
  void _selectImage() async {
    final imagePath = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageSelectionScreen(),
      ),
    );

    if (imagePath != null) {
      setState(() {
        _selectedImage = imagePath;
      });
    }
  }

  // Función para seleccionar un archivo de audio.
  void _selectAudio() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final audioPaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/audios/'))
        .where((String path) => _isAudioFile(path))
        .toList();

    final selectedAudioPath = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleccionar un audio"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: audioPaths.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(audioPaths[index].split('/').last)),
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () async {
                          String modifiedPath =
                              audioPaths[index].replaceFirst('assets/', '');
                          await _audioPlayer.play(AssetSource(modifiedPath),
                              mode: PlayerMode.lowLatency);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _audioPlayer.stop();
                    Navigator.of(context).pop(audioPaths[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedAudioPath != null) {
      setState(() {
        _sonido = selectedAudioPath;
      });
      // Reproduce el archivo de audio seleccionado
      print("La ruta del audio es --> " + selectedAudioPath);
      String modifiedPath = selectedAudioPath.replaceFirst('assets/', '');
      await _audioPlayer.play(AssetSource(modifiedPath),
          mode: PlayerMode.lowLatency);
    }
  }

  // Función para verificar si una ruta es un archivo de audio.
  bool _isAudioFile(String path) {
    final allowedExtensions = ['.mp3', '.wav', '.ogg'];
    return allowedExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
}
