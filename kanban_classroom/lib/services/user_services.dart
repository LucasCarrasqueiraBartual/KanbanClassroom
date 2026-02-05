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

      // 1. Crear usuario en Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // 2. Crear objeto User para nuestra base de datos NoSQL
      final newUser = User(
        id: credential.user!.uid,
        nombre: nombre,
        email: email,
        verificado: true,
        tableros: {
          credential.user!.uid: "Mi Tablero Personal" // Tablero inicial por defecto
        },
      );

      // 3. Guardar en Realtime Database 
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

  // --- LOGIN CON FIREBASE AUTH 
  Future<String?> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      //  Validar credenciales en Firebase Auth
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
      print("Error al cargar usuario de la base de datos: $e");
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    tempUser = null;
    notifyListeners();
  }

  // --- MÉTODOS (CRUD USUARIOS) 
  
  Future<void> saveOrCreateUser() async {
    if (tempUser == null) return;
    
    final url = Uri.https(_baseUrl, 'users/${tempUser!.id}.json');
    await http.put(url, body: tempUser!.toJson());
    notifyListeners();
  }

  //TODO Método para  administrador
  Future<void> loadAllUsers() async {
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
    }

    isLoading = false;
    notifyListeners();
  }

  //  TODO:
  //  TODO:
  //  TODO:

}