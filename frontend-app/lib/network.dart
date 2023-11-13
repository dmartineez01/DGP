import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Modelos/ElementoTarea.dart';
import 'Modelos/Tarea.dart';

// Función para obtener administradores
Future<List<dynamic>> fetchAdministradores() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/administradores'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load admin data');
  }
}

// Función para obtener alumnos
Future<List<dynamic>> fetchAlumnos() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/alumnos'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load student data');
  }
}

Future<dynamic> fetchAlumno(int id) async {
  final url = Uri.parse('http://10.0.2.2:3000/alumnos/$id');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load student data');
  }
}


Future<bool> addStudent(String nombre, String password, bool imagen, bool texto, bool audio) async {
  final url = Uri.parse('http://10.0.2.2:3000/alumnos');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      'nombre': nombre,
      'password': password,
      'imagen': imagen ? 1 : 0,  // Clave en minúsculas
      'texto': texto ? 1 : 0,    // Clave en minúsculas
      'audio': audio ? 1 : 0,    // Clave en minúsculas
    }),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    return responseBody['status'] == 'success';
  } else {
    throw Exception('Failed to add student');
  }
}

Future<bool> deleteAlumno(int id) async {
  final url = Uri.parse('http://10.0.2.2:3000/alumnos/$id');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to delete student');
  }
}

Future<bool> updateAlumno(int id, String nombre, int imagen, int texto, int audio, String password) async {
  final url = Uri.parse('http://10.0.2.2:3000/alumnos/$id');
  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      'nombre': nombre,
      'password': password,
      'Imagen': imagen,
      'Texto': texto,
      'Audio': audio,
    }),
  );
  return response.statusCode == 200;
}


// Función para obtener tareas
Future<List<Tarea>> fetchTareas() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/tareas'));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((task) => Tarea(
      id: task['id'],
      nombre: task['nombre'],
      tipo: task['tipo'],
    )).toList();
  } else {
    throw Exception('Failed to load tasks');
  }
}

// Función para obtener elementos de tarea
Future<List<ElementoTarea>> fetchElementosTarea(int tareaId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/tareas/$tareaId/elementos'));
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> data = jsonResponse['elementos'];
    return data.map((elemento) => ElementoTarea(
      id: elemento['id'],
      pictograma: elemento['pictograma'],
      descripcion: elemento['descripcion'],
      sonido: elemento['sonido'],
      video: elemento['video'],
    )).toList();
  } else {
    throw Exception('Failed to load task elements for task $tareaId');
  }
}

// Función para añadir tarea
Future<Tarea> addTarea(String nombre, String tipo) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:3000/tareas'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'nombre': nombre,
      'tipo': tipo,
    }),
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    return Tarea(id: jsonResponse['id'], nombre: nombre, tipo: tipo);
  } else {
    throw Exception('Failed to add task');
  }
}

// Función para añadir un elemento de tarea
Future<ElementoTarea> addElementoTarea(String pictograma, String descripcion, String sonido, String? video, int tareaId) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:3000/tareas/$tareaId/elementos'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'pictograma': pictograma,
      'descripcion': descripcion,
      'sonido': sonido,
      'video': video,
    }),
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    return ElementoTarea(
      id: jsonResponse['id'],
      pictograma: pictograma,
      descripcion: descripcion,
      sonido: sonido,
      video: video,
    );
  } else {
    throw Exception('Failed to add task element');
  }
}

Future<int?> assignTaskToStudent(int alumnoId, int tareaId, String tipo) async {
  final response;
  if (tipo == "Material") {
    response = await http.post(
      Uri.parse('http://10.0.2.2:3000/alumnos/$alumnoId/asignar-material'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "alumno_id": alumnoId, // Agrega el campo alumno_id
        "tarea_id": tareaId,   // Agrega el campo tarea_id
      }),
    );
  } else if (tipo == "Fija") {

    print("holaaaaa");
    response = await http.post(
      Uri.parse('http://10.0.2.2:3000/alumnos/$alumnoId/asignar-tarea-fija'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "alumno_id": alumnoId, // Agrega el campo alumno_id
        "tarea_id": tareaId,   // Agrega el campo tarea_id
      }),
    );
  } else if (tipo == "Comanda") {
    response = await http.post(
      Uri.parse('http://10.0.2.2:3000/alumnos/$alumnoId/asignar-tarea-comanda'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "alumno_id": alumnoId, // Agrega el campo alumno_id
        "tarea_id": tareaId,   // Agrega el campo tarea_id
      }),
    );
  } else {
    // Tipo de tarea desconocido, maneja el error como consideres apropiado
    return null;
  }

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['id']; // Suponiendo que el ID es retornado bajo la clave 'id'
  } else {
    return null;
  }
}


Future<bool> asignarCantidadMaterialElemento(int materialAsignadaId, int elementoTareaId, int cantidad) async {
  final url = Uri.parse('http://10.0.2.2:3000/material-elemento');
  final headers = {"Content-Type": "application/json"};
  final body = json.encode({
    "materialAsignada_id": materialAsignadaId,
    "elementoTarea_id": elementoTareaId,
    "cantidad": cantidad,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final success = responseData['success'] as bool;
      return success;
    } else {
      // Handle error cases, e.g., by throwing an exception or returning false.
      return false;
    }
  } catch (e) {
    // Handle network-related errors, e.g., by throwing an exception or returning false.
    return false;
  }
}



// Función para obtener tareas asignadas a un alumno
Future<List<dynamic>> fetchAllAssignedTasksForStudent(int alumnoId) async {
  final List<dynamic> allTasks = [];

  // Obtener tareas de tipo Material
  final materialTasksResponse = await http.get(Uri.parse('http://10.0.2.2:3000/alumnos/$alumnoId/materiales-asignados'));
  if (materialTasksResponse.statusCode == 200) {
    final materialTasks = json.decode(materialTasksResponse.body);
    allTasks.addAll(materialTasks['materialesAsignados']);
  }

  // Obtener tareas de tipo Tarea Fija
  final fijaTasksResponse = await http.get(Uri.parse('http://10.0.2.2:3000/alumnos/$alumnoId/tareas-fijas-asignadas'));
  print(fijaTasksResponse.body);
  if (fijaTasksResponse.statusCode == 200) {
    final fijaTasks = json.decode(fijaTasksResponse.body);
    allTasks.addAll(fijaTasks['tareasFijasAsignadas']);
  }

  // Obtener tareas de tipo Tarea Comanda
  final comandaTasksResponse = await http.get(Uri.parse('http://10.0.2.2:3000/alumnos/$alumnoId/tareas-comandas-asignadas'));
  if (comandaTasksResponse.statusCode == 200) {
    final comandaTasks = json.decode(comandaTasksResponse.body);
    allTasks.addAll(comandaTasks['tareasComandasAsignadas']);
  }

  return allTasks;
}

