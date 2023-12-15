// Importación de bibliotecas necesarias.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

// Clase que representa la pantalla de selección de imágenes.
class ImageSelectionScreen extends StatefulWidget {
  @override
  _ImageSelectionScreenState createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadImagesFromAssets();
  }

  // Carga las imágenes desde los activos.
  Future<void> _loadImagesFromAssets() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final imagePaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/pictogramas/'))
        .where((String path) => _isImageFile(path))
        .toList();
    setState(() {
      this.imagePaths = imagePaths;
    });
  }

  // Comprueba si un archivo es una imagen basándose en su extensión.
  bool _isImageFile(String path) {
    final ext = extension(path).toLowerCase();
    return ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.gif';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Imagen'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Número de imágenes por línea
          crossAxisSpacing: 4.0, // Espaciado horizontal entre imágenes
          mainAxisSpacing: 4.0, // Espaciado vertical entre imágenes
        ),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => Navigator.of(context).pop(imagePaths[index]),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2), // Borde para distinguir las imágenes
              ),
              child: Image.asset(imagePaths[index], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}
