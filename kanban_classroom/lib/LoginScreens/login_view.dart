import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_classroom/models/task_model.dart';
import 'package:kanban_classroom/models/user_model.dart';
import 'package:kanban_classroom/services/services.dart';
import '../MainScreens/kanban_screen.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final taskService = Provider.of<TaskService>(context, listen: false);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.house, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text("Bienvenido", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              userService.isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    onPressed: () async {
                      final error = await userService.login(emailCtrl.text.trim(), passCtrl.text.trim());
                      
                      if (error == null) {
                        await taskService.loadTasks(userService.tempUser!.id!);
                        if (mounted) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const KanbanScreen()));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                      }
                    },
                    child: const Text("Iniciar Sesión"),
                  ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes cuenta? "),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterView())),
                    child: const Text("¡Regístrate ya!"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}