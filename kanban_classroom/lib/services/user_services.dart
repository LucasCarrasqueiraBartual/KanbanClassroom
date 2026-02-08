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

  // --- MÉTODOS DE AUTENTICACIÓN DE USUARIO

    // Metodo de comprpovación
    Future<void> checkCurrentUser() async {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await loadUserById(currentUser.uid);
      }
    }

    // Metodo para resgistrarse
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

    // Metodo para realizar el login 
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
            final Map<String, dynamic> data = json.decode(response.body);
            tempUser = User.fromMap(data);
            tempUser!.id = uid; // Forzamos que el ID sea el de Auth
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

// -- METODOS DE ACTUALIZACIÓN DE UN USUARIO

  Future<String?> updateUserName(String newName) async {
    try {
      if (tempUser == null) return "No hay sesión activa";
      
      isLoading = true;
      notifyListeners();

      final uid = tempUser!.id; 
      
      final url = Uri.https(_baseUrl, 'users/$uid.json');
      
      await http.patch(url, body: json.encode({
        'nombre': newName
      }));
      tempUser!.nombre = newName;
      
      return null; 
    } catch (e) {
      return 'Error al actualizar nombre';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> deleteUserAccount() async {
    String? error;
    final user = _firebaseAuth.currentUser;
    if (user == null) return "No hay sesión activa";
    
    final uid = user.uid; 

    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.https(_baseUrl, 'users/$uid.json');
      await http.delete(url);

      await user.delete();
      
      tempUser = null;
      error = null;
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        error = "RE-AUTH";
      } else {
        error = e.message;
      }
    } catch (e) {
      error = "Error al eliminar cuenta";
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return error;
  }

  Future<Map<String, String>?> findUserByEmail(String email) async {
    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.https(_baseUrl, 'users.json');
      final response = await http.get(url);

      if (response.body == 'null' || response.body.isEmpty) return null;

      final Map<String, dynamic> data = json.decode(response.body);

      for (var entry in data.entries) {
        final userData = entry.value as Map<String, dynamic>;
        if (userData['email'].toString().toLowerCase() == email.toLowerCase().trim()) {
          return {
            'id': entry.key,
            'nombre': userData['nombre'] ?? 'Sin nombre',
            'email': userData['email']
          };
        }
      }
      return null; 
    } catch (e) {
      print("Error buscando usuario: $e");
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
      Future<String?> compartirTablero({
  required String emailInvitado,
  required String boardId, 
  required String boardNombre,
}) async {
  try {
    isLoading = true;
    notifyListeners();

    final invitado = await findUserByEmail(emailInvitado);
    if (invitado == null) return "Usuario no encontrado";
    final invitadoId = invitado['id']!;

    final urlUser = Uri.https(_baseUrl, 'users/$invitadoId/tableros.json');
    await http.patch(urlUser, body: json.encode({
      boardId: boardNombre 
    }));

    final urlBoard = Uri.https(_baseUrl, 'boards/$boardId/colaboradores.json');
    await http.patch(urlBoard, body: json.encode({
      invitadoId: true
    }));

    return null; 
  } catch (e) {
    return "Error: $e";
  } finally {
    isLoading = false;
    notifyListeners();
  }
 }
}