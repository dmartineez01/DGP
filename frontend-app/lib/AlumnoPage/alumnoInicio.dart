import 'package:flutter/material.dart';
import 'package:frontend_app/AlumnoPage/Tareas/tareasAlumno.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AlumnoInicioPage extends StatefulWidget {
  final dynamic alumno;
  final String image;

  AlumnoInicioPage({Key? key, required this.alumno, required this.image})
      : super(key: key);

  @override
  _AlumnoInicioPageState createState() => _AlumnoInicioPageState();
}

class _AlumnoInicioPageState extends State<AlumnoInicioPage> {

    @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      setState(() {
        // Tu lógica que depende de los locales va aquí, por ejemplo, actualizar la UI
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildProfileInfo(widget.alumno['nombre'], widget.image),
          _buildDayIndicator(),
          Expanded(
            child: ListView(
              children: [
                _buildAccessibleCard('HISTORIAL', 'assets/pictogramas/historial.jpg'),
                _buildAccessibleCard('TAREAS', 'assets/pictogramas/tareas.jpg'),
              ],
            ),
          ),
          _buildExitButton(),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String name, String imagePath) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage("assets/images/" + imagePath),
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDayIndicator() {
  // Configura el local para español
  String dayLetter = DateFormat('EEEE', 'es_ES').format(DateTime.now())[0].toUpperCase();
  List<String> days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: days.map((String letter) {
        bool isToday = dayLetter == letter;
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isToday ? Colors.green : Colors.transparent,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 20,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Colors.white : Colors.grey,
            ),
          ),
        );
      }).toList(),
    ),
  );
}


  Widget _buildAccessibleCard(String title, String imageAsset) {
    return GestureDetector(
      onTap: () {
      if (title == 'TAREAS') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TareasAlumnoPage(alumnoId: widget.alumno['id']), // Pasamos el ID del alumno aquí
          ),
        );
      } else {
        // Lógica para ir al histórico o cualquier otra tarjeta
      }
    },
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Image.asset(
              imageAsset,
              height: 150, // 80% de la altura asignada para la imagen
              fit: BoxFit.fitWidth,
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              color: Colors.grey[200],
              child: Text(
                title,
                style: TextStyle(fontSize: 20), // Tamaño de fuente basado en el tamaño disponible
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildExitButton() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.exit_to_app),
        label: Text('Salir', style: TextStyle(fontSize: 20)),
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
          onPrimary: Colors.white,
          minimumSize: Size(double.infinity, 50), // make it stretch
        ),
      ),
    );
  }
}
