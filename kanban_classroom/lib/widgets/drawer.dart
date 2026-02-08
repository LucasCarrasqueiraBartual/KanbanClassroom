import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_classroom/services/services.dart';
import 'package:kanban_classroom/LoginScreens/login_view.dart';

class KanbanDrawer extends StatelessWidget {
  const KanbanDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final taskService = Provider.of<TaskService>(context);
    final boardService = Provider.of<BoardService>(context); 

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
                  onPressed: () => _showCreateBoardDialog(context, userService, boardService),
                )
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (user.tableros.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No hay tableros", style: TextStyle(color: Colors.grey)),
                  ),
                  ...user.tableros.entries.where((e) => e.key.isNotEmpty).map((entry) {
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
                    // botton de borrar
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _confirmDeleteBoard(
                        context, 
                        entry.key, 
                        entry.value, 
                        boardService, 
                        userService, 
                        taskService
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

    // FUNCION PARA CONFIRMAR ELIMINACION
  void _confirmDeleteBoard(
    BuildContext context, 
    String boardId, 
    String boardName, 
    BoardService boardService, 
    UserService userService,
    TaskService taskService
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar tablero?"),
        content: Text("¿Estás seguro de eliminar '$boardName'? Esta acción no se puede deshacer."),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),

          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cierra el diálogo
              
              // Llama a tu servicio de borrado
              await boardService.deleteBoard(boardId, userService.tempUser!.id!, userService);
              // Si el tablero borrado es el que está abierto, limpiamos la selección
              if (taskService.selectedBoardId == boardId) {
                taskService.selectedBoardId = '';
              }
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  // --- FUNCIÓN PARA DIALOG de creacion Tablero
  void _showCreateBoardDialog(BuildContext context, UserService userService, BoardService boardService) {
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
              final error = await boardService.createBoard(
                boardName.trim(), 
                userService.tempUser!.id!,
                userService 
              );
              
              if (context.mounted) {
                if (error == null) {
                  final taskService = Provider.of<TaskService>(context, listen: false);
                  
                  if (userService.tempUser!.tableros.isNotEmpty) {
                    final newId = userService.tempUser!.tableros.entries
                        .lastWhere((e) => e.value == boardName.trim()).key;
                    
                    taskService.selectedBoardId = newId;
                  }
                  Navigator.pop(context); 
                  Navigator.pop(context); 
                } else {
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