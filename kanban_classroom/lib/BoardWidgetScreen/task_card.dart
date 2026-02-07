import 'package:flutter/material.dart';
import 'package:kanban_classroom/models/models.dart';
import 'package:kanban_classroom/services/services.dart';

class TaskCard extends StatelessWidget {
 
  final TaskModel task;
  final TaskService service;
  final VoidCallback onTap;

  const TaskCard({
    super.key, 
    required this.task, 
    required this.service, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<TaskModel>(  
      delay: const Duration(milliseconds: 140),           
      data: task, 
        feedback: Material(
        elevation: 20, 
        color: Colors.transparent, 
        child: Transform.rotate(
          angle: 0.05, 
          child: SizedBox(
            width: 260, 
            child: _cardItem(), 
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3, 
        child: _cardItem(), 
      ),
      child: GestureDetector(
        onTap: onTap,
        child: _cardItem(),
      ),
    );
  }

  Widget _cardItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => service.deleteTask(task.id!),
                ),
              ],
            ),
            if (task.description.isNotEmpty)
              Text(task.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.person, size: 12, color: Colors.indigo),
                const SizedBox(width: 4),
                Text(task.author, style: const TextStyle(fontSize: 10)),
                const Spacer(),
                const Icon(Icons.access_time, size: 12, color: Colors.orange),
                const SizedBox(width: 4),
                Text("${task.dueDate.day}/${task.dueDate.month}", style: const TextStyle(fontSize: 10)),
              ],
            )
          ],
        ),
      ),
    );
  }
}