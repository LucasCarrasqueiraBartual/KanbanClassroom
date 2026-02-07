import 'dart:convert';

class TaskModel {
  String? id;
  String title;
  String columnId;
  String boardId;
  String description;
  String author;     
  DateTime dueDate;   

  TaskModel({
    this.id,
    required this.title,
    this.columnId = 'todo',
    this.boardId = 'personal',
    this.description = '',
    this.author = '',    
    DateTime? dueDate,   
  }) : dueDate = dueDate ?? DateTime.now();


  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
        title: map["title"] ?? '',
        columnId: map["columnId"] ?? 'todo',
        boardId: map["boardId"] ?? 'personal',
        description: map["description"] ?? '',
        author: map["author"] ?? 'Sin autor',
        dueDate: DateTime.parse(map["dueDate"] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toMap() => {
        "title": title,
        "columnId": columnId,
        "boardId": boardId,
        "description": description,
        "author": author,
        "dueDate": dueDate.toIso8601String(),
      };

  String toJson() => json.encode(toMap());

  // Método  para copiar una tarea no modificar la original 
  TaskModel copy() => TaskModel(
    id: id,
    title: title,
    columnId: columnId,
    boardId: boardId,
    description: description,
    author: author,
    dueDate: dueDate,
  );
}