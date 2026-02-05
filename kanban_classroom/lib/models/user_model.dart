import 'dart:convert';

class User {

  String? id;
  String nombre;
  String email;
  bool verificado; 
  Map<String, dynamic> tableros;

  User({
    this.id,
    required this.nombre,
    required this.email,
    this.verificado = false,
    this.tableros = const {},
  });


  factory User.fromMap(Map<String, dynamic> json) => User(
    nombre: json["nombre"] ?? '',
    email: json["email"] ?? '',
    verificado: json["verificado"] ?? false, 
    tableros: Map<String, dynamic>.from(json["tableros"] ?? {}),
  );


  Map<String, dynamic> toMap() => {
    "nombre": nombre,
    "email": email,
    "verificado": verificado,
    "tableros": tableros,
  };


  String toJson() => json.encode(toMap());
}