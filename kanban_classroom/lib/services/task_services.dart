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
  
  // setter para que cargue tareas automáticamente al cambiar de tablero
  set selectedBoardId(String val) {
    _selectedBoardId = val;
    loadTasks(val); 
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

  // --- MÉTODOS HTTP ---

  Future<void> loadTasks(String boardId) async {
    if (boardId.isEmpty) return;
    
    try {
      isLoading = true;
      _selectedBoardId = boardId; 

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

  // GUARDAR O CREAR TAREA
  Future<void> saveOrCreateTask() async {
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

  // CREAR NUEVO TABLERO 
  Future<void> createBoard(String userId, String boardName) async {
    try {
      final boardUrl = Uri.https(_baseUrl, 'boards.json');
      final boardData = {
        'nombre': boardName,
        'creador': userId,
        'fechaCreacion': DateTime.now().toIso8601String(),
      };
      
      final response = await http.post(boardUrl, body: json.encode(boardData));
      final Map<String, dynamic> decodedResp = json.decode(response.body);
      final String newBoardId = decodedResp['name']; 

      final userBoardUrl = Uri.https(_baseUrl, 'users/$userId/tableros/$newBoardId.json');
      await http.put(userBoardUrl, body: json.encode(boardName));

      selectedBoardId = newBoardId;
      
    } catch (e) {
      print("Error al crear tablero: $e");
    }
  }

  // 4. MOVER TAREa
  Future<void> moveTask(TaskModel task, String newColId) async {
    final oldColId = task.columnId;
    task.columnId = newColId;
    notifyListeners();

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