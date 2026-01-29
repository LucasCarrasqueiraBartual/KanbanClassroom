import 'package:flutter/material.dart';
import 'kanban_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Bienvenido", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const TextField(
              decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const KanbanView())),
              child: const Text("Iniciar Sesión"),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.login), // Aquí iría el logo de Google
              label: const Text("Iniciar sesión con Google"),
              onPressed: () { /* Lógica de Google */ },
            ),
          ],
        ),
      ),
    );
  }
}