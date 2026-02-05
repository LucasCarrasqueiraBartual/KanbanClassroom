import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kanban_classroom/models/task_model.dart';
import 'package:kanban_classroom/models/user_model.dart';
import 'package:http/http.dart' as http;


class UserService extends ChangeNotifier {
  final String _baseUrl = "kanban-proyect-default-rtdb.europe-west1.firebasedatabase.app"; // <--- CAMBIA ESTO
  
  List<User> users = [];
  late User tempUser; 
  bool isLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  UserService() {
    _resetTempUser();
    loadUsers();
  }

  void _resetTempUser() {
    tempUser = User(
      nombre: '',
      email: '',
      verificado: false,
      tableros: {}, 
    );
  }

  Future<void> loadUsers() async {
    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.https(_baseUrl, 'users.json');
      final response = await http.get(url);

      users.clear();

      if (response.body != 'null' && response.body.isNotEmpty) {
        final Map<String, dynamic> usersMap = json.decode(response.body);
        
        usersMap.forEach((key, value) {
          final auxUser = User.fromMap(value);
          auxUser.id = key;
          users.add(auxUser);
        });

        if (users.isNotEmpty) {
          tempUser = users[0];
        }
      }
    } catch (e) {
      print("Error en UserService: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // metodos CRUD users ->
}