import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kanban_classroom/models/models.dart';
import 'package:kanban_classroom/services/services.dart';

class BoardService extends ChangeNotifier {      //Provider  del tablero

  final String _baseUrl = "kanban-proyect-default-rtdb.europe-west1.firebasedatabase.app"; 
  List<BoardModel> boards = [];
  bool isLoading = false;

  // --- METODOS CRUD DEL TABLERO 
  Future<String?> createBoard(String boardName, String userId, UserService userService) async {
    try {
      isLoading = true;
      notifyListeners();

      final newBoard = BoardModel(
        nombre: boardName,
        creadorId: userId,
        fechaCreacion: DateTime.now(),
      );

      // Guardar tablero /boards
      final url = Uri.https(_baseUrl, 'boards.json');
      final resp = await http.post(url, body: newBoard.toJson());
      final decodedData = json.decode(resp.body);
      final String boardId = decodedData['name'];

      final userUrl = Uri.https(_baseUrl, 'users/$userId/tableros/$boardId.json');
      await http.put(userUrl, body: json.encode(boardName));
      
        // Actualizamos el modelo del usuario se actualice al instante.
      if (userService.tempUser != null) {
        userService.tempUser!.tableros[boardId] = boardName;
      }
            newBoard.id = boardId; 
      boards.add(newBoard);

      return null; 
    } catch (e) {
      print("Error createBoard: $e");
      return "Error al crear tablero";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBoard(String boardId, String userId, UserService userService) async {
    try {                                      
      isLoading = true;                // Hay que eliminar todo antes de elimnar un board
      notifyListeners();

      // Eliminar el tablero de /boards
      final urlBoard = Uri.https(_baseUrl, 'boards/$boardId.json');
      await http.delete(urlBoard);
      final urlUser = Uri.https(_baseUrl, 'users/$userId/tableros/$boardId.json');
      await http.delete(urlUser);

      final urlTasks = Uri.https(_baseUrl, 'tasks/$boardId.json');
      await http.delete(urlTasks);

      // Actualizar localmente el UserService para que desaparezca del Drawer
      if (userService.tempUser != null) {
        userService.tempUser!.tableros.remove(boardId);
      }
      
      boards.removeWhere((b) => b.id == boardId);

    } catch (e) {
      print("Error borrando tablero: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}