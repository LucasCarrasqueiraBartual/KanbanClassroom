import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as auth; 
import 'package:kanban_classroom/models/user_model.dart';

class UserService extends ChangeNotifier {
  final String _baseUrl = "kanban-proyect-default-rtdb.europe-west1.firebasedatabase.app";
  
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  
  List<User> users = [];
  User? tempUser; 
  bool isLoading = false;

  UserService() {
    checkCurrentUser();
  }

  // --- MÉTODOS DE TABLEROS ---

  // Crea un nuevo tablero y vincula al usuario actual
  Future<String?> createBoard(String boardName) async {
    if (tempUser == null) return "No hay un usuario activo";

    try {
      isLoading = true;
      notifyListeners();

      final boardsUrl = Uri.https(_baseUrl, 'boards.json');
      final boardData = {
        'nombre': boardName,
        'creadorId': tempUser!.id,
        'fechaCreacion': DateTime.now().toIso8601String(),
      };

      final response = await http.post(boardsUrl, body: json.encode(boardData));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResp = json.decode(response.body);
        final String newBoardId = decodedResp['name']; 

        // Actualizar el perfil del usuario local y en la nube
        tempUser!.tableros[newBoardId] = boardName;

        final userUrl = Uri.https(_baseUrl, 'users/${tempUser!.id}/tableros/$newBoardId.json');
        await http.put(userUrl, body: json.encode(boardName));

        notifyListeners();
        return null; 
      } else {
        return "Error al conectar con el servidor";
      }
    } catch (e) {
      print("Error en createBoard: $e");
      return "Error al crear el tablero";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODOS DE AUTENTICACIÓN 

  Future<void> checkCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await loadUserById(currentUser.uid);
    }
  }

  Future<String?> registerUser({
    required String email, 
    required String password, 
    required String nombre
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      final newUser = User(
        id: credential.user!.uid,
        nombre: nombre,
        email: email,
        verificado: true,
        tableros: {
          credential.user!.uid: "Mi Tablero Personal" 
        },
      );

      final url = Uri.https(_baseUrl, 'users/${newUser.id}.json');
      await http.put(url, body: newUser.toJson());

      tempUser = newUser;
      return null; 
    } on auth.FirebaseAuthException catch (e) {
      return e.message; 
    } catch (e) {
      return "Ocurrió un error inesperado al registrar.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      await loadUserById(credential.user!.uid);
      
      return null; 
    } on auth.FirebaseAuthException catch (e) {
      return "Credenciales incorrectas o usuario no encontrado.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserById(String uid) async {
    try {
      final url = Uri.https(_baseUrl, 'users/$uid.json');
      final response = await http.get(url);

      if (response.body != 'null' && response.body.isNotEmpty) {
        tempUser = User.fromMap(json.decode(response.body));
        tempUser!.id = uid;
      }
    } catch (e) {
      print("Error al cargar usuario: $e");
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    tempUser = null;
    notifyListeners();
  }

  Future<void> saveOrCreateUser() async {
    if (tempUser == null) return;
    
    final url = Uri.https(_baseUrl, 'users/${tempUser!.id}.json');
    await http.put(url, body: tempUser!.toJson());
    notifyListeners();
  }
}