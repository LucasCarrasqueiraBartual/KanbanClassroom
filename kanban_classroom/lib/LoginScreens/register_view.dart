import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_services.dart';
import '../MainScreens/kanban_screen.dart';

class RegisterView extends StatefulWidget { // Pantalla para realizar rgistro 
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [

            const Text("Registrate", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            TextField(                      // Para recojer el nombre del usuario 
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),
            TextField(                       // Para recojer el nombre del usuario 
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),
            TextField(                       // Para recojer la contraseña del usuario 
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
            ),
            
            const SizedBox(height: 24),     //procesamiento del registro en firebase y validación
            userService.isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Rellena todos los campos (Pass: min. 6 caracteres)"))
                      );
                      return;
                    }
                          // registro en el backend a través del servicio.
                    final error = await userService.registerUser(
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                      nombre: nameCtrl.text.trim(),
                    );

                    if (error == null) {
                      if (mounted) {   //Volvemos al tablero principal si se registro de forma exitosa
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const KanbanScreen()));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text("Registrarse y Entrar"),
                ),
          ],
        ),
      ),
    );
  }
}