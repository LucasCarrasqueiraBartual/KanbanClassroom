import 'dart:convert';

class TaskModel {

  String? id;
  String title;
  String columnId;
  String boardId;
  String description;

  TaskModel({

    this.id,
    required this.title,
    this.columnId = 'todo',
    this.boardId = 'personal', 
    this.description = '', 
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    title: map["title"] ?? '',
    columnId: map["columnId"] ?? 'todo',
    boardId: map["boardId"] ?? 'personal', 
    description: map["description"] ?? '', 
  );

  Map<String, dynamic> toMap() => {
    "title": title,
    "columnId": columnId,
    "boardId": boardId,
    "description": description,
  };

  String toJson() => json.encode(toMap());
}