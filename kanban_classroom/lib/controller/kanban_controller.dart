import 'package:flutter/material.dart';
import 'package:kanban_classroom/model/task_model.dart';

class KanbanController extends ChangeNotifier {
  // Listas de datos privadas
  final List<Task> _todo = [Task(id: '1', title: 'Diseñar Base de Datos')];
  final List<Task> _doing = [Task(id: '2', title: 'Configurar Controller')];
  final List<Task> _done = [Task(id: '3', title: 'Setup del Proyecto')];

  // Getters para acceder a las listas
  List<Task> get todo => _todo;
  List<Task> get doing => _doing;
  List<Task> get done => _done;

  // Lógica para reordenar dentro de una misma columna
  void reorderTask(List<Task> list, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    notifyListeners(); // Notifica a la UI del cambio
  }

  // Lógica para añadir una tarea
  void addTask(String title) {
    _todo.add(Task(id: DateTime.now().toString(), title: title));
    notifyListeners();
  }
}