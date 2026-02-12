import 'package:googleapis/classroom/v1.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kanban_classroom/services/AuthenticatedClient.dart';

class ClassroomService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      ClassroomApi.classroomCoursesReadonlyScope,
    ],
  );

  ClassroomApi? _classroomApi;

  /// Login + inicialización + print automático
  Future<void> signInAndPrintCourses() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();

    if (account == null) {
      print("Login cancelado");
      return;
    }

    print("Usuario logeado: ${account.email}");

    final headers = await account.authHeaders;
    final client = AuthenticatedClient(headers);

    _classroomApi = ClassroomApi(client);

    await _printCourses();
  }

  Future<void> _printCourses() async {
    if (_classroomApi == null) return;

    final response = await _classroomApi!.courses.list();

    final courses = response.courses;

    if (courses == null || courses.isEmpty) {
      print("No hay cursos disponibles");
      return;
    }

    print("===== CURSOS DEL USUARIO =====");

    for (var course in courses) {
      print("ID: ${course.id}");
      print("Nombre: ${course.name}");
      print("Sección: ${course.section}");
      print("---------------------------");
    }
  }
}
