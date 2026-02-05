import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_classroom/services/task_services.dart';
import 'package:kanban_classroom/services/user_services.dart';

class KanbanDrawer extends StatelessWidget {
  const KanbanDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final taskService = Provider.of<TaskService>(context);

    if (userService.tempUser == null) {
      return const Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final user = userService.tempUser!;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            accountName: Text(user.nombre),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.nombre.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 24, color: Colors.indigo),
              ),
            ),
          ),
          const ListTile(
            title: Text("MIS TABLEROS", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: user.tableros.entries.map((entry) {
                final bool isSelected = taskService.selectedBoardId == entry.key;
                
                return ListTile(
                  leading: Icon(
                    Icons.dashboard_outlined,
                    color: isSelected ? Colors.indigo : null,
                  ),
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? Colors.indigo : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    taskService.selectedBoardId = entry.key;
                    taskService.loadTasks(entry.key);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Cerrar Sesión"),
            onTap: () async {
              await userService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, 'login'); 
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}