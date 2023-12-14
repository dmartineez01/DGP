import "ElementoTarea.dart";

class Tarea {
  int id;
  String nombre;
  String tipo;

  Tarea({
    required this.id,
    required this.nombre,
    required this.tipo,
  });

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      tipo: map['tipo'] as String,
    );
  }
}
