import 'package:flutter/material.dart';
import 'package:kanban_classroom/services/task_services.dart';
import 'package:kanban_classroom/services/user_services.dart';

import 'package:provider/provider.dart';

class KanbanDrawer extends StatelessWidget {
  const KanbanDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final taskService = Provider.of<TaskService>(context, listen: false);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userService.tempUser.nombre),
            accountEmail: Text(userService.tempUser.email),
            currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("MIS TABLEROS", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          // Generamos la lista de tableros dinámicamente desde el User
          Expanded(
            child: ListView(
              children: userService.tempUser.tableros.entries.map((entry) {
                return ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: Text(entry.value), 
                  selected: taskService.selectedBoardId == entry.key,
                  onTap: () {
                    // 1. Cambiamos el tablero activo
                    taskService.selectedBoardId = entry.key;
                    // 2. Cargamos las tareas de esa carpeta específica
                    taskService.loadTasks(entry.key);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}