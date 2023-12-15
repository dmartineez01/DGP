import 'package:flutter/material.dart';
import 'package:frontend_app/AlumnoPage/Historial/historialAlumno.dart';
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

  // Inicialización de locales para formateo de fechas en español
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      setState(() {
        // La inicialización de locales permite formatear fechas en español
      });
    });
  }

  // Construye la interfaz de usuario de la página principal del alumno
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
                _buildAccessibleCard('HISTORIAL', 'assets/pictogramas/historial.png'),
                _buildAccessibleCard('TAREAS', 'assets/pictogramas/tareas.jpg'),
              ],
            ),
          ),
          _buildExitButton(),
        ],
      ),
    );
  }

  // Construye la información del perfil del alumno en la parte superior de la página
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

  // Construye el indicador de días de la semana con íconos y colores
  Widget _buildDayIndicator() {
    String todayFull = DateFormat('EEEE', 'es_ES').format(DateTime.now()).toLowerCase();
    List<Map<String, dynamic>> days = [
      {'name': 'lunes', 'icon': Icons.wb_sunny, 'color': Colors.yellow},
      {'name': 'martes', 'icon': Icons.cloud, 'color': Colors.blue},
      {'name': 'miércoles', 'icon': Icons.grass, 'color': Colors.green},
      {'name': 'jueves', 'icon': Icons.water, 'color': Colors.teal},
      {'name': 'viernes', 'icon': Icons.sports_soccer, 'color': Colors.orange},
      {'name': 'sábado', 'icon': Icons.music_note, 'color': Colors.purple},
      {'name': 'domingo', 'icon': Icons.cake, 'color': Colors.pink},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: days.map((day) {
          bool isToday = todayFull == day['name'];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isToday ? day['color'] : Colors.transparent,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: <Widget>[
                  Icon(day['icon'], color: isToday ? Colors.white : day['color'], size: 20),
                  SizedBox(width: 2),
                  Text(
                    isToday ? day['name'].replaceFirst(day['name'][0], day['name'][0].toUpperCase()) : "",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Construye tarjetas de acceso a funciones como historial y tareas
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
        } else if (title == 'HISTORIAL') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistorialAlumnoPage(alumnoId: widget.alumno['id']), // Pasamos el ID del alumno aquí
            ),
          );
        }
      },
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Semantics(
              label: 'Imagen representativa de $title', // Descripción alternativa para accesibilidad
              child: Image.asset(
                imageAsset,
                height: 150, // Altura asignada para la imagen
                fit: BoxFit.fitWidth,
              ),
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

  // Construye el botón de salida de la aplicación
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
          minimumSize: Size(double.infinity, 50), // Hace que el botón se estire
        ),
      ),
    );
  }
}
