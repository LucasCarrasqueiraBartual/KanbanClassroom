import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/task_model.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kanban_classroom/models/task_model.dart';

class TaskService extends ChangeNotifier {
  final String _baseUrl = "kanban-proyect-default-rtdb.europe-west1.firebasedatabase.app"; 
  List<TaskModel> tasks = [];
  bool isLoading = false;

  String _selectedBoardId = 'user_prueba_123';
  late TaskModel _tempTask;

  String get selectedBoardId => _selectedBoardId;
  set selectedBoardId(String val) {
    _selectedBoardId = val;
    notifyListeners();
  }

  TaskModel get tempTask => _tempTask;
  set tempTask(TaskModel val) {
    _tempTask = val;
    notifyListeners();
  }

  TaskService() {
    _resetTempTask();
  }

  void _resetTempTask() {
    _tempTask = TaskModel(
      title: '', 
      description: '', 
      columnId: 'todo', 
      boardId: _selectedBoardId
    );
  }

  // --- MÉTODOS HTTP 

  // 1. CARGAR TAREAS 
  Future<void> loadTasks(String boardId) async {
    try {
      isLoading = true;
      _selectedBoardId = boardId; 
      notifyListeners();

      final url = Uri.https(_baseUrl, 'tasks/$boardId.json');
      final response = await http.get(url);

      tasks.clear();
      if (response.body != 'null' && response.body.isNotEmpty) {
        final Map<String, dynamic> tasksMap = json.decode(response.body);
        tasksMap.forEach((key, value) {
          final auxTask = TaskModel.fromMap(value);
          auxTask.id = key;
          tasks.add(auxTask);
        });
      }
    } catch (e) {
      print("Error cargando tareas: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 2. GUARDAR O CREAR 
  Future<void> saveOrCreateTask() async {
    try {
      if (_tempTask.id == null) {
        final url = Uri.https(_baseUrl, 'tasks/$_selectedBoardId.json');
        await http.post(url, body: _tempTask.toJson());
      } else {
        final url = Uri.https(_baseUrl, 'tasks/$_selectedBoardId/${_tempTask.id}.json');
        await http.put(url, body: _tempTask.toJson());
      }
      _resetTempTask();
      loadTasks(_selectedBoardId); 
    } catch (e) {
      print("Error al guardar: $e");
    }
  }

  // 3. MOVER TAREA 
  Future<void> moveTask(TaskModel task, String newColId) async {
    task.columnId = newColId;
    notifyListeners();

    try {
      final url = Uri.https(_baseUrl, 'tasks/$_selectedBoardId/${task.id}.json');
      await http.put(url, body: task.toJson());
    } catch (e) {
      print("Error al mover: $e");
      loadTasks(_selectedBoardId);
    }
  }

  // 4. ELIMINAR TAREA
  Future<void> deleteTask(String taskId) async {
    try {
      final url = Uri.https(_baseUrl, 'tasks/$_selectedBoardId/$taskId.json');
      await http.delete(url);
      
      tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      print("Error al borrar: $e");
    }
  }
}