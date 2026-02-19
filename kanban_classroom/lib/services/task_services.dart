import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kanban_classroom/models/models.dart';
import 'package:kanban_classroom/services/notification_services.dart';

class TaskService extends ChangeNotifier {  //Provider para la gestión de tareas 
  final String _baseUrl =
      'kanban-proyect-default-rtdb.europe-west1.firebasedatabase.app';

  List<TaskModel> tasks = [];
  bool isLoading = false;

  String _selectedBoardId = '';
  late TaskModel _tempTask;

  String get selectedBoardId => _selectedBoardId;

  TaskModel get tempTask => _tempTask;
  set tempTask(TaskModel val) {
    _tempTask = val;
    notifyListeners();
  }

  TaskService() {
    _resetTempTask();
  }
 // metodo para reiniciarl el temp taskc 
  void _resetTempTask() {
    _tempTask = TaskModel(
      title: '',
      description: '',
      columnId: 'todo',
      boardId: _selectedBoardId,
    );
  }

  // Al cambiar de tablero, cargamos automáticamente sus tareas.
  set selectedBoardId(String val) {
    if (_selectedBoardId == val) return;
    _selectedBoardId = val;
    loadTasks(val);
    notifyListeners();
  }

  // Obatener tareas de un tablero especifico
  Future<void> loadTasks(String boardId) async {        
    if (boardId.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.https(_baseUrl, 'tasks/$boardId.json');
      final response = await http.get(url);

      if (response.body != 'null' && response.body.isNotEmpty) {
        final Map<String, dynamic> tasksMap = json.decode(response.body);
        final List<TaskModel> newTasks = [];
        tasksMap.forEach((key, value) {
          final auxTask = TaskModel.fromMap(value);
          auxTask.id = key;
          newTasks.add(auxTask);
        });
        tasks = newTasks;
      } else {
        tasks = [];
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> saveOrCreateTask() async {
    if (_selectedBoardId.isEmpty) return;
    try {
      _tempTask.boardId = _selectedBoardId;
      String? taskId = _tempTask.id;

      if (_tempTask.id == null) {
        // creación:  POST .
        final url = Uri.https(_baseUrl, 'tasks/$_selectedBoardId.json');
        final response = await http.post(url, body: _tempTask.toJson());

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          taskId = data['name'];
        }
      } else {
        // edición:  PUT .
        final url =
            Uri.https(_baseUrl, 'tasks/$_selectedBoardId/${_tempTask.id}.json');
        await http.put(url, body: _tempTask.toJson());

        await NotificationService.cancelarAvisoTarea(taskId.hashCode);
      }

      await NotificationService.programarAvisoTarea(
        id: taskId.hashCode,
        titulo: _tempTask.title,
        fechaEntrega: _tempTask.dueDate,
      );

      _resetTempTask();
      await loadTasks(_selectedBoardId);
    } catch (e) {
      print('Error al guardar y programar notificacion: $e');
    }
  }

  //  permite el Drag & Drop visual la move tareas.
  Future<void> moveTask(TaskModel task, String newColId) async {
    final oldColId = task.columnId;
    task.columnId = newColId;
    notifyListeners();
    try {
      final url = Uri.https(_baseUrl, 'tasks/$_selectedBoardId/${task.id}.json');
      final response = await http.put(url, body: task.toJson());

      if (response.statusCode >= 400) throw Exception();
    } catch (e) {
      print('Error al mover: $e');
      task.columnId = oldColId;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await NotificationService.cancelarAvisoTarea(taskId.hashCode);
      final url = Uri.https(_baseUrl, 'tasks/$_selectedBoardId/$taskId.json');
      await http.delete(url);

      tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      print('Error al borrar la tarea o la notificacion: $e');
    }
  }

  Future<void> replaceBoardTasks(String boardId, List<TaskModel> newTasks) async {
    if (boardId.isEmpty) return;

    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.https(_baseUrl, 'tasks/$boardId.json');
      final Map<String, dynamic> payload = {};

      for (int i = 0; i < newTasks.length; i++) {
        final task = newTasks[i];
        task.boardId = boardId;
        task.columnId = task.columnId.isEmpty ? 'todo' : task.columnId;
        payload['classroom_$i'] = task.toMap();
      }

      await http.put(url, body: payload.isEmpty ? 'null' : json.encode(payload));

      if (_selectedBoardId == boardId) {
        await loadTasks(boardId);
      } else {
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error reemplazando tareas del tablero: $e');
      isLoading = false;
      notifyListeners();
    }
  }
}
