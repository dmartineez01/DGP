import 'package:flutter/material.dart';
import 'package:frontend_app/AlumnoPage/alumnoInicio.dart';
import 'package:frontend_app/Widgets/menuController.dart';

class LoginImageAlumno extends StatefulWidget {
  final dynamic alumno;
  final String image;

  LoginImageAlumno({Key? key, required this.alumno, required this.image})
      : super(key: key);

  @override
  _LoginImageAlumnoState createState() => _LoginImageAlumnoState();
}

class _LoginImageAlumnoState extends State<LoginImageAlumno> {
  List<int> selectedImageIndices = [];
  List<String> imageOptions = [
    "contraseña1.jpg",
    "contraseña2.jpg",
    "contraseña3.jpg",
    "contraseña4.jpg",
    "contraseña5.jpg",
    "contraseña6.jpg"
  ];

  void _selectImage(int index) {
  int adjustedIndex = index + 1; // Ajusta el índice para que comience en 1
  List<int> newSequence = [...selectedImageIndices, adjustedIndex];

  // Construye la secuencia como un string para la comparación
  String nextSequence = newSequence.map((idx) => idx.toString()).join('');

  // Solo procede si la secuencia es correcta hasta este punto
  if (widget.alumno['password'].startsWith(nextSequence)) {
    setState(() {
      selectedImageIndices = newSequence; // Actualiza con la nueva secuencia
    });

    // Verifica si la secuencia completa es correcta
    if (nextSequence == widget.alumno['password']) {
      _navigateToInicioPage();
    }
  } else {
    // Si la secuencia no es correcta, muestra error y comienza de nuevo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Secuencia de imágenes incorrecta')),
    );
    setState(() {
      selectedImageIndices.clear(); // Limpia la secuencia para empezar de nuevo
    });
  }
}

void _navigateToInicioPage() {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) =>
        AlumnoInicioPage(alumno: widget.alumno, image: widget.image),
  ));
}


  void _checkImageSequence() {
    // Convierte la secuencia de índices en la secuencia de números como string
    String selectedSequence =
        selectedImageIndices.map((idx) => (idx + 1).toString()).join('');

    // Si la secuencia seleccionada es igual a la contraseña, navega a la página de inicio
    if (selectedSequence == widget.alumno['password']) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            AlumnoInicioPage(alumno: widget.alumno, image: widget.image),
      ));
    }
  }

  Widget _buildSelectedImages() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: selectedImageIndices.asMap().entries.map((entry) {
          int idx = entry.key;
          int index = entry.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/images/${imageOptions[index]}',
                  width: 50,
                  height: 50,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${idx + 1}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          botonSalir(),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: imageOptions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _selectImage(index),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedImageIndices.contains(index+1)
                                ? Colors.green
                                : Colors.grey,
                            width: selectedImageIndices.contains(index+1) ? 5 : 1,
                          ),
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/${imageOptions[index]}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Imágenes seleccionadas:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildSelectedImages(),
        ],
      ),
    );
  }
}
