import 'package:flutter/material.dart';
import 'package:kanban_classroom/view/google_login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google SignIn',
      home: GoogleLoginPage(),
    );
  }
}