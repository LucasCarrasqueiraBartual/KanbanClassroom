import 'package:flutter/material.dart';
import 'package:kanban_classroom/models/models.dart';
import 'package:kanban_classroom/BoardWidgetScreen/task_card.dart';
import 'package:kanban_classroom/services/task_services.dart'; 

class KanbanBoard extends StatelessWidget {

  final TaskService taskService;
  final String userId;
  final Function(TaskModel) onEditTask; 

  const KanbanBoard({
    super.key, 
    required this.taskService, 
    required this.userId, 
    required this.onEditTask
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, 
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            KanbanColumn(title: "PENDIENTE", colId: "todo", tasks: taskService.tasks, service: taskService, onEditTask: onEditTask),
            KanbanColumn(title: "EN PROCESO", colId: "process", tasks: taskService.tasks, service: taskService, onEditTask: onEditTask),
            KanbanColumn(title: "HECHO", colId: "done", tasks: taskService.tasks, service: taskService, onEditTask: onEditTask),
          
          ],
        ),
      ),
    );
  }
}

class KanbanColumn extends StatelessWidget {

  final String title;
  final String colId;
  final List<TaskModel> tasks;
  final TaskService service;
  final Function(TaskModel) onEditTask; 

  const KanbanColumn({
    super.key, 
    required this.title, 
    required this.colId, 
    required this.tasks, 
    required this.service,
    required this.onEditTask
  });

  @override
  Widget build(BuildContext context) {

    final columnTasks = tasks.where((t) => t.columnId == colId).toList();

    return DragTarget<TaskModel>(
     
      onWillAcceptWithDetails: (details) => details.data.columnId != colId, 
      onAcceptWithDetails: (details) => service.moveTask(details.data, colId), 
      builder: (context, candidateData, rejectedData) {
       
        return AnimatedContainer(

          duration: const Duration(milliseconds: 300),
          width: 300, 
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
          color: candidateData.isNotEmpty 
                ? Colors.white.withOpacity(0.2) 
                : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: candidateData.isNotEmpty 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.2), 
              width: 1.5
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Text(
                  title, 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, 
                    letterSpacing: 2,
                    fontSize: 14
                  )
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: columnTasks.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TaskCard(
                      task: columnTasks[index], 
                      service: service,
                      onTap: () => onEditTask(columnTasks[index]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}