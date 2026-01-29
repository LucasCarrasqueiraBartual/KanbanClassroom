import 'package:flutter/material.dart';
import 'kanban_view.dart';
import 'register_view.dart'; // Importamos la nueva vista

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
            // Botón de Google con imagen personalizada
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              icon: Image.asset('assets/google.png', height: 24), // Imagen solicitada
              label: const Text("Iniciar sesión con Google"),
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            // Texto para navegar al registro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("No tienes cuenta? "),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const RegisterView())),
                  child: const Text(
                    "Registrate ya!",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}