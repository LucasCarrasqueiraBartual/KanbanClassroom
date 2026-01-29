import 'package:flutter/material.dart';
import 'package:kanban_classroom/view/kanban_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Kanban Demo',
      debugShowCheckedModeBanner: false,
      // Configuramos un tema global estilo Material 3
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      // La vista que creamos en el archivo anterior
      home: const KanbanView(),
    );
  }
}