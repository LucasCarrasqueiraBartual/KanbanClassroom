import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_classroom/services/services.dart';
import '../MainScreens/kanban_screen.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {     //  Pantalla principal del login al iniciar
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

              Image.asset(
                'assets/images/logo.png',
                height: 80,
              ),              
              const SizedBox(height: 20),
              const Text("Bienvenido", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              TextField(                              // Para recojer el email
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),const SizedBox(height: 16),

              TextField(                              // Para recojer la contraseña
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
              ),const SizedBox(height: 24),

              userService.isLoading             //Procesamiento del login
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    onPressed: () async {
                      final error = await userService.login(emailCtrl.text.trim(), passCtrl.text.trim());
                      
                      if (error == null) {
                        final user = userService.tempUser;
                        if (user != null && user.id != null) {
                          await taskService.loadTasks(user.id!);
                          
                          if (mounted) {
                            Navigator.pushReplacement(context, 
                              MaterialPageRoute(builder: (_) => const KanbanScreen())
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error: No se encontraron datos del perfil en la base de datos."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error), backgroundColor: Colors.red)
                          );
                        }
                      }
                    },
                    child: const Text("Iniciar Sesion"),
                  ),

              const SizedBox(height: 20),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("O"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),const SizedBox(height: 16),
                                                        // autenticación con Google.
              userService.isLoading 
                ? const SizedBox.shrink()
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () async {
                      final error = await userService.loginWithGoogle();
                      
                      if (error == null) {
                        final user = userService.tempUser;
                        if (user != null && user.id != null) {
                          await taskService.loadTasks(user.id!);
                          if (mounted) {
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (_) => const KanbanScreen())
                            );
                          }
                        }
                      } else if (error != "Login cancelado") {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error), backgroundColor: Colors.red)
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_circle, color: Colors.red),
                        const SizedBox(width: 10),
                        const Text("Continuar con Google", style: TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes cuenta? "),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterView())),
                    child: const Text("¡Registrate ya!"),
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