import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_classroom/services/task_services.dart';
import 'package:kanban_classroom/services/user_services.dart';

import 'package:kanban_classroom/LoginScreens/login_view.dart';

class KanbanDrawer extends StatelessWidget {
  const KanbanDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final taskService = Provider.of<TaskService>(context);

    if (userService.tempUser == null) {
      return const Drawer(child: Center(child: CircularProgressIndicator()));
    }
    final user = userService.tempUser!;

    return Drawer(
      backgroundColor: const Color.fromARGB(230, 255, 255, 255),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color.fromARGB(200, 67, 103, 145)),
            accountName: Text(user.nombre),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.nombre.isNotEmpty ? user.nombre.substring(0, 1).toUpperCase() : "?",
                style: const TextStyle(fontSize: 24, color: Color.fromARGB(255, 67, 103, 145)),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("MIS TABLEROS", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color.fromARGB(255, 67, 103, 145)),
                  onPressed: () => _showCreateBoardDialog(context, userService),
                )
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // LISTA DE TABLEROS EXISTENTES
                ...user.tableros.entries.map((entry) {
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
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Cerrar Sesión"),
            onTap: () async {
              await userService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false, 
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- FUNCIÓN PARA DIALO
  void _showCreateBoardDialog(BuildContext context, UserService userService) {
    String boardName = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuevo Tablero"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Ej: Proyecto Final, Compras...",
            labelText: "Nombre del tablero",
          ),
          onChanged: (value) => boardName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 67, 103, 145),
            ),
           onPressed: () async {
                if (boardName.trim().isNotEmpty) {
                  //  Creamos el tablero en el UserService
                  final error = await userService.createBoard(boardName.trim());
                  
                  if (context.mounted) {
                    if (error == null) {
                      final taskService = Provider.of<TaskService>(context, listen: false);

                      //  Buscamos el ID del tablero recién creado
                      final newBoardId = userService.tempUser!.tableros.keys.last;
                      
                      //  Cambiamos el tablero activo
                      taskService.selectedBoardId = newBoardId;
                      
                      Navigator.pop(context); 
                      Navigator.pop(context); 
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error))
                      );
                    }
                  }
                }
              },
            child: const Text("CREAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}