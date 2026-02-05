import 'package:flutter/material.dart';
import 'package:kanban_classroom/models/task_model.dart';
import 'package:provider/provider.dart';
import 'package:kanban_classroom/services/task_services.dart';
import 'package:kanban_classroom/services/user_services.dart';
import 'package:kanban_classroom/widgets/drawer.dart';


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
        title: Text(currentBoardName),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const KanbanDrawer(),
      body: taskService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _KanbanBoard(taskService: taskService, userId: taskService.selectedBoardId),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () => _showAddTaskDialog(context, taskService),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  void _showAddTaskDialog(BuildContext context, TaskService service) {
    String title = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Tarea"),
        content: TextField(
          onChanged: (val) => title = val,
          decoration: const InputDecoration(hintText: "Título de la tarea"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              service.tempTask = TaskModel(title: title, description: '', boardId: service.selectedBoardId);
              service.saveOrCreateTask();
              Navigator.pop(context);
            }, 
            child: const Text("Guardar")
          ),
        ],
      ),
    );
  }
}


class _KanbanBoard extends StatelessWidget {
  final TaskService taskService;
  final String userId;
  const _KanbanBoard({required this.taskService, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KanbanColumn(title: "PENDIENTE", colId: "todo", tasks: taskService.tasks, service: taskService),
            _KanbanColumn(title: "EN PROCESO", colId: "process", tasks: taskService.tasks, service: taskService),
            _KanbanColumn(title: "HECHO", colId: "done", tasks: taskService.tasks, service: taskService),
          ],
        ),
      ),
    );
  }
}


class _KanbanColumn extends StatelessWidget {
  final String title;
  final String colId;
  final List<TaskModel> tasks;
  final TaskService service;

  const _KanbanColumn({required this.title, required this.colId, required this.tasks, required this.service});

  @override
  Widget build(BuildContext context) {
    final columnTasks = tasks.where((t) => t.columnId == colId).toList();

    return DragTarget<TaskModel>(
      onAccept: (task) => service.moveTask(task, colId),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 280,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty ? Colors.indigo[50] : Colors.white70,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: columnTasks.length,
                  itemBuilder: (context, index) => _TaskCard(task: columnTasks[index], service: service),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final TaskService service;
  const _TaskCard({required this.task, required this.service});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<TaskModel>(
      data: task,
      feedback: Material(
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(20),
          color: Colors.indigoAccent,
          child: Text(task.title, style: const TextStyle(color: Colors.white)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _cardItem()),
      child: _cardItem(),
    );
  }

  Widget _cardItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(task.title),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
          onPressed: () => service.deleteTask(task.id!),
        ),
      ),
    );
  }
}