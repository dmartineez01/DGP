import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:frontend_app/AdminPage/Tareas/InfoTarea.dart';
import '../../Modelos/ElementoTarea.dart';
import '../../Modelos/Tarea.dart';
import '../../network.dart';
import 'agregarTarea.dart';

class TareasPage extends StatefulWidget {
  @override
  _TareasPageState createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  late Future<List<Tarea>> futureTareas;
  List<dynamic>? _filteredTareas; // Lista filtrada
  TextEditingController _searchController = TextEditingController();
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    futureTareas = fetchTareas();
  }

  void _filterTareas(String query) {
    if (query.isNotEmpty) {
      futureTareas.then((tareas) {
        setState(() {
          _filteredTareas = tareas
              .where((tarea) =>
                  tarea.nombre.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      });
    } else {
      setState(() {
        _filteredTareas = null;
      });
    }
  }

  Future<List<ElementoTarea>> _fetchAndSetElementos(int tareaId) async {
    return await fetchElementosTarea(tareaId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ZoomDrawer.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagina Tareas'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            controller?.toggle();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Tareas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Tarea por nombre',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterTareas('');
                  },
                ),
              ),
              onChanged: (value) => _filterTareas(value),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Tarea>>(
                future: futureTareas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      // Lista de tareas a mostrar (filtradas o todas)
                      final tareasList = _filteredTareas ?? snapshot.data!;

                      return ListView.builder(
                        itemCount: tareasList.length,
                        itemBuilder: (context, index) {
                          final tarea = tareasList[index];

                          return ExpansionTile(
                            title: Text('ID: ${tarea.id} - ${tarea.nombre}'),
                            subtitle: Text(tarea.tipo),
                            trailing: // Dentro de TareasPage, cuando abres InfoTarea:
                                IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        InfoTarea(tarea: tarea),
                                  ),
                                );
                                if (result == true) {
                                  // Si se devuelve 'true', actualiza la lista de tareas
                                  setState(() {
                                    futureTareas = fetchTareas();
                                  });
                                }
                              },
                            ),
                            children: <Widget>[
                              FutureBuilder<List<ElementoTarea>>(
                                future: fetchElementosTarea(tarea.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      return Column(
                                        children: snapshot.data!
                                            .map((e) => Container(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 16.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        spreadRadius: 1,
                                                        blurRadius: 7,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          'Imagen',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  10.0),
                                                        ),
                                                        child: Image.asset(
                                                          e.pictograma,
                                                          fit: BoxFit.contain,
                                                          height: 200,
                                                          width:
                                                              double.infinity,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Descripción',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              e.descripcion,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14.0),
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            Text(
                                                              'Sonido',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    e.sonido
                                                                        .split(
                                                                            '/')
                                                                        .last,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .play_arrow,
                                                                      color: Colors
                                                                          .blue),
                                                                  onPressed:
                                                                      () async {
                                                                    String modifiedPath = e
                                                                        .sonido
                                                                        .replaceFirst(
                                                                            'assets/',
                                                                            '');
                                                                    await _audioPlayer.play(
                                                                        AssetSource(
                                                                            modifiedPath),
                                                                        mode: PlayerMode
                                                                            .lowLatency);
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
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("${snapshot.error}");
                                    }
                                  }
                                  return CircularProgressIndicator();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("${snapshot.error}"));
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTaskPage(),
                  ),
                );
                setState(() {
                  futureTareas = fetchTareas();
                });
              },
              child: Text('Añadir Tarea'),
            ),
          ],
        ),
      ),
    );
  }
}
