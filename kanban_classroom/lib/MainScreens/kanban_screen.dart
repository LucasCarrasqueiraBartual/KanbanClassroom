import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kanban_classroom/MainScreens/user_profile_screen.dart';
import 'package:kanban_classroom/services/classroom_services.dart';
import 'package:provider/provider.dart';
import 'package:kanban_classroom/services/services.dart';
import 'package:kanban_classroom/models/models.dart';
import 'package:kanban_classroom/widgets/drawer.dart';
import 'package:kanban_classroom/BoardWidgetScreen/Board.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

          // Método para sincronizar datos al cargar
  void _onInit(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final classroomService = Provider.of<ClassroomService>(context, listen: false);
      final userService = Provider.of<UserService>(context, listen: false);
      final boardService = Provider.of<BoardService>(context, listen: false);
      final taskService = Provider.of<TaskService>(context, listen: false);
      
      classroomService.syncClassroomToKanban(
        userService: userService,
        boardService: boardService,
        taskService: taskService,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
  
    _onInit(context);

    final taskService = Provider.of<TaskService>(context);
    final userService = Provider.of<UserService>(context);

    if (userService.tempUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String currentBoardName = userService.tempUser!.tableros[taskService.selectedBoardId] ?? "Tablero Personal";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          taskService.selectedBoardId.isEmpty ? "Kanban Classroom" : currentBoardName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withOpacity(0.2),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          if (taskService.selectedBoardId.isNotEmpty)

            IconButton(                         //Boton para recargar las tareas
              icon: taskService.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.refresh),
              tooltip: "Refrescar tareas",
              onPressed: taskService.isLoading ? null : () => taskService.loadTasks(taskService.selectedBoardId),
            ),
          if (taskService.selectedBoardId.isNotEmpty)

            IconButton(                               //Boton para compartir
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: "Compartir tablero",
              onPressed: () => _mostrarDialogoCompartir(context),
            ),

          IconButton(                                   // Boton para redirigirse a al gestor de perfil 
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileView()),
            ),

          ),
        ],
      ),
      drawer: const KanbanDrawer(),               // Acceso al Menu lateral desplegable
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0EAFC),
                  Color.fromARGB(255, 67, 103, 145),
                  Color.fromARGB(255, 79, 121, 150),
                ],
              ),
            ),
          ),
          SafeArea(
            child: taskService.selectedBoardId.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () => taskService.loadTasks(taskService.selectedBoardId),
                    color: Colors.indigo,
                    child: taskService.isLoading && taskService.tasks.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : KanbanBoard(
                            taskService: taskService,
                            userId: taskService.selectedBoardId,
                            onEditTask: (p1) => _showTaskDialog(context, taskService, task: p1),
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: taskService.selectedBoardId.isEmpty       // Boton para crear nuevas tareas
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.indigo.withOpacity(0.8),
              elevation: 4,
              onPressed: () => _showTaskDialog(context, taskService),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  // --- MÉTODOS AUXILIARES 

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_outlined, size: 100, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text(
            "No hay ningun tablero seleccionado",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
          ),
          const Text(
            "Abre el menu y crea uno nuevo",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
                                                            //Dialogo para mostrar la seccón de compartir
  void _mostrarDialogoCompartir(BuildContext context) {
    final emailController = TextEditingController();
    final userService = Provider.of<UserService>(context, listen: false);
    final taskService = Provider.of<TaskService>(context, listen: false);
    final String boardIdActual = taskService.selectedBoardId;
    final String boardNombreActual = userService.tempUser?.tableros[boardIdActual] ?? "Tablero Compartido";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Color.fromARGB(255, 67, 103, 145)),
            SizedBox(width: 10),
            Text("Compartir Tablero"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Compartiendo: $boardNombreActual", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Introduce el email del colaborador:"),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email del colaborador",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email == userService.tempUser?.email) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ya eres el dueño de este tablero")));
                return;
              }
              if (email.isNotEmpty) {
                final error = await userService.compartirTablero(
                  emailInvitado: email,
                  boardId: boardIdActual,
                  boardNombre: boardNombreActual,
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? "¡Tablero compartido con éxito!"),
                      backgroundColor: error == null ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("COMPARTIR"),
          ),
        ],
      ),
    );
  }
                                              // dialogo para modificar tareas o crea
  void _showTaskDialog(BuildContext context, TaskService service, {TaskModel? task}) {  
    final isEditing = task != null;
    final temp = isEditing
        ? task.copy()
        : TaskModel(
            title: '',
            boardId: service.selectedBoardId,
            author: Provider.of<UserService>(context, listen: false).tempUser?.nombre ?? '',
          );
                                            
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder( 
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 229, 237, 245).withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            title: Text(isEditing ? "Editar Tarea" : "Nueva Tarea", textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: temp.title)..selection = TextSelection.collapsed(offset: temp.title.length),
                    onChanged: (val) => temp.title = val,
                    decoration: const InputDecoration(labelText: "Titulo"),
                  ),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(text: temp.description),
                    onTap: () => _showDescriptionEditor(context, temp, setDialogState),
                    decoration: const InputDecoration(
                      labelText: "Descripcion (clic para editar)",
                      suffixIcon: Icon(Icons.open_in_full),
                    ),
                  ),
                  TextField(
                    controller: TextEditingController(text: temp.author),
                    onChanged: (val) => temp.author = val,
                    decoration: const InputDecoration(labelText: "Autor de la tarea"),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text("Entrega: ${temp.dueDate.day}/${temp.dueDate.month}/${temp.dueDate.year}"),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: temp.dueDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setDialogState(() => temp.dueDate = picked);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(
                onPressed: () {
                  service.tempTask = temp;
                  service.saveOrCreateTask();
                  Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDescriptionEditor(                // para visualizar la descripción                              
    BuildContext context,
    TaskModel temp,
    void Function(void Function()) setDialogState,
  ) async {
    var draftDescription = temp.description;

    final updatedDescription = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar descripcion"),
        content: SizedBox(
          width: double.maxFinite,
          height: 320,
          child: TextFormField(
            initialValue: draftDescription,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            expands: true,
            onChanged: (value) => draftDescription = value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Escribe aqui la descripcion...",
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(draftDescription),
            child: const Text("Aplicar"),
          ),
        ],
      ),
    );

    if (updatedDescription != null) {
      temp.description = updatedDescription;
      setDialogState(() {});          // Actualiza el diálogo de la tarea
    }
  }
}