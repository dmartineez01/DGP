import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../network.dart';

class TareasPendientesAdminPage extends StatefulWidget {
  @override
  _TareasPendientesAdminPageState createState() => _TareasPendientesAdminPageState();
}

class _TareasPendientesAdminPageState extends State<TareasPendientesAdminPage> {
  

  @override
  Widget build(BuildContext context) {
    final controller = ZoomDrawer.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Administradores'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            controller?.toggle();
          },
        ),
      ),
      body: Text("Aqui estaran las tareas pendientes de confirmar por el administrador")
    );
  }
}
