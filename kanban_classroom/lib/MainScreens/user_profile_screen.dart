import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_classroom/services/services.dart';
import 'package:kanban_classroom/LoginScreens/login_view.dart'; 

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final user = userService.tempUser;

    String nombreTemporal = user?.nombre ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración de Perfil"),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color.fromARGB(255, 67, 103, 145),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  TextFormField(
                    initialValue: user.nombre,
                    decoration: const InputDecoration(
                      labelText: "Nombre Completo",
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => nombreTemporal = value,
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    initialValue: user.email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: "Correo Electrónico",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 67, 103, 145),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: userService.isLoading
                          ? null
                          : () async {
                              if (nombreTemporal.trim().isEmpty) return;
                              final error = await userService.updateUserName(nombreTemporal);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error ?? "Nombre actualizado correctamente"),
                                    backgroundColor: error == null ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                      child: userService.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("GUARDAR CAMBIOS",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  TextButton.icon(
                    onPressed: userService.isLoading 
                      ? null 
                      : () => _confirmarEliminacion(context, userService),
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      "ELIMINAR MI CUENTA",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Función para mostrar el diálogo de confirmación
  void _confirmarEliminacion(BuildContext context, UserService userService) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog( 
      title: const Text("¿Eliminar cuenta?"),
      content: const Text(
          "Esta acción es permanente. Si la sesión ha expirado, el sistema te pedirá volver a entrar por seguridad."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("CANCELAR"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx); 
            final error = await userService.deleteUserAccount();

            if (!context.mounted) return;

            if (error == null) {
              await userService.logout(); 
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error), backgroundColor: Colors.red),
              );

              if (error.contains("re-iniciar") || error.contains("seguridad") || error == "RE-AUTH") {
                await userService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                    (route) => false,
                  );
                }
              }
            }
          },
          child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
}