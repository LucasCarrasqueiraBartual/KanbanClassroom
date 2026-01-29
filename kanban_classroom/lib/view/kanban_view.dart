import 'package:flutter/material.dart';
import 'package:kanban_classroom/controller/kanban_controller.dart';
import 'package:kanban_classroom/model/task_model.dart';

class KanbanView extends StatefulWidget {
  const KanbanView({super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  // Instanciamos el controlador
  final KanbanController _controller = KanbanController();

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios para redibujar la UI
    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kanban Architecture')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildColumn("Pendiente", _controller.todo, Colors.red),
            _buildColumn("Proceso", _controller.doing, Colors.blue),
            _buildColumn("Hecho", _controller.done, Colors.green),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _controller.addTask("Nueva Tarea"),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildColumn(String title, List<Task> tasks, Color color) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          ListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: ReorderableListView(
              onReorder: (old, nxt) => _controller.reorderTask(tasks, old, nxt),
              children: tasks.map((t) => Card(
                key: ValueKey(t.id),
                child: ListTile(title: Text(t.title)),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}