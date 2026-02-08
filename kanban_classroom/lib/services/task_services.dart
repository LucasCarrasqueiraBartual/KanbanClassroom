import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kanban_classroom/models/models.dart';

class TaskService extends ChangeNotifier {
  final String _baseUrl = "kanban-proyect-default-rtdb.europe-west1.firebasedatabase.app"; 

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

  void _resetTempTask() {
    _tempTask = TaskModel(
      title: '', 
      description: '', 
      columnId: 'todo', 
      boardId: _selectedBoardId 
    );
  }

  set selectedBoardId(String val) {
      if (_selectedBoardId == val) return; 
      _selectedBoardId = val;
      loadTasks(val); 
      notifyListeners();
    }


  // --- MÉTODOS HTTP 
  
    Future<void> loadTasks(String boardId) async {
      if (boardId.isEmpty) return;
      
      isLoading = true;
      notifyListeners(); 

      try {
        final url = Uri.https(_baseUrl, 'tasks/$boardId.json');
        final response = await http.get(url);

        if (response.body != 'null' && response.body.isNotEmpty) {
          final Map<String, dynamic> tasksMap = json.decode(response.body);
          List<TaskModel> newTasks = [];
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
        print("Error: $e");
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }

  // GUARDAR O CREAR TAREA
  Future<void> saveOrCreateTask() async {
    if (_selectedBoardId.isEmpty) {
      print("Error: Intentando guardar tarea sin tablero seleccionado");
      return;
    }
  
  try {
    _tempTask.boardId = _selectedBoardId;

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

  // MOVER TAREA 
  Future<void> moveTask(TaskModel task, String newColId) async {
    final oldColId = task.columnId;
    task.columnId = newColId;
    notifyListeners(); // movemos en la UI antes de enviar al servidor

    try {
      final url = Uri.https(_baseUrl, 'tasks/$_selectedBoardId/${task.id}.json');
      final response = await http.put(url, body: task.toJson());
      
      if (response.statusCode >= 400) throw Exception();
    } catch (e) {
      print("Error al mover: $e");
      task.columnId = oldColId;
      notifyListeners();
    }
  }

  // ELIMINAR TAREA
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