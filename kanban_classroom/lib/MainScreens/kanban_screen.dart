import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_classroom/services/services.dart';
import 'package:kanban_classroom/models/models.dart';
import 'package:kanban_classroom/widgets/drawer.dart';
import 'package:kanban_classroom/BoardWidgetScreen/Board.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final taskService = Provider.of<TaskService>(context);
    final userService = Provider.of<UserService>(context);

    if (userService.tempUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    String currentBoardName = userService.tempUser!.tableros[taskService.selectedBoardId] ?? "Tablero Personal";
   
    return Scaffold(
      appBar: AppBar(
        title: Text(currentBoardName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white.withOpacity(0.2),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      drawer: const KanbanDrawer(),
      body: Stack( //  Stack para las capas, gradiente
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                 Color(0xFFE0EAFC), 
                 Color.fromARGB(255, 67, 103, 145), 
                 Color.fromARGB(255, 79, 121, 150), 
                ],
              ),
            ),
          ),
          SafeArea( 
            child: taskService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : KanbanBoard(
                    taskService: taskService, 
                    userId: taskService.selectedBoardId, 
                    onEditTask: (p1) => _showTaskDialog(context, taskService, task: p1),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.withOpacity(0.8),
        elevation: 4,
        onPressed: () => _showTaskDialog(context, taskService),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );}


  void _showTaskDialog(BuildContext context, TaskService service, {TaskModel? task}) {
  
    final isEditing = task != null;
    final temp = isEditing 
        ? task.copy() 
        : TaskModel(title: '', boardId: service.selectedBoardId, author: Provider.of<UserService>(context, listen: false).tempUser?.nombre ?? '');

  showDialog(
  context: context,
  builder: (context) => BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
    child: StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 229, 237, 245).withOpacity(0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        title: Text(
          isEditing ? "Editar Tarea" : "Nueva Tarea",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), 
            fontSize: 22,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

                TextField(
                    controller: TextEditingController(text: temp.title)..selection = TextSelection.collapsed(offset: temp.title.length),
                    onChanged: (val) => temp.title = val,
                    decoration: const InputDecoration(labelText: "Título"),
                ),

                TextField(
                    controller: TextEditingController(text: temp.description),
                    onChanged: (val) => temp.description = val,
                    decoration: const InputDecoration(labelText: "Descripción"),
                ),
                TextField(
                  controller: TextEditingController(text: temp.author),
                  onChanged: (val) => temp.author = val,
                  decoration: const InputDecoration(
                    labelText: "Autor de la tarea"
                  ),
                ), 
                 const SizedBox(height: 20),
              
                ListTile(
                  contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text("Entrega: ${temp.dueDate.day}/${temp.dueDate.month}/${temp.dueDate.year}"),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: temp.dueDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => temp.dueDate = picked);
                  },
                ),
              ],
            ),
          ),  actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                      ElevatedButton(
                        onPressed: () {
                          service.tempTask = temp;
                          service.saveOrCreateTask();
                          Navigator.pop(context);
                        },
                        child: const Text("Guardar"),
                      ),
                ],
          ),
    ),
  )
  );
 }
}

