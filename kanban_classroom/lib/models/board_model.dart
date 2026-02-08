import 'dart:convert';

class BoardModel {
  String? id;
  String nombre;
  String creadorId;
  DateTime fechaCreacion;

  BoardModel({
    this.id,
    required this.nombre,
    required this.creadorId,
    required this.fechaCreacion,
  });

  factory BoardModel.fromMap(Map<String, dynamic> map) => BoardModel(
    nombre: map['nombre'],
    creadorId: map['creadorId'],
    fechaCreacion: DateTime.parse(map['fechaCreacion']),
  );

  String toJson() => json.encode({
    'nombre': nombre,
    'creadorId': creadorId,
    'fechaCreacion': fechaCreacion.toIso8601String(),
  });
}