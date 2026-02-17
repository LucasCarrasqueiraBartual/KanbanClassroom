import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/classroom/v1.dart';
import 'package:kanban_classroom/models/task_model.dart';
import 'package:kanban_classroom/services/AuthenticatedClient.dart';
import 'package:kanban_classroom/services/board_services.dart';
import 'package:kanban_classroom/services/task_services.dart';
import 'package:kanban_classroom/services/user_services.dart';

class ClassroomService {
  static const String _boardPrefix = 'Classroom - ';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      ClassroomApi.classroomCoursesReadonlyScope,
      ClassroomApi.classroomCourseworkMeReadonlyScope,
      ClassroomApi.classroomStudentSubmissionsMeReadonlyScope,
    ],
  );

  ClassroomApi? _classroomApi;

  Future<void> syncClassroomToKanban({
    required UserService userService,
    required BoardService boardService,
    required TaskService taskService,
  }) async {
    try {
      final GoogleSignInAccount? account =
          await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

      if (account == null) {
        print('Login Classroom cancelado');
        return;
      }

      final headers = await account.authHeaders;
      final client = AuthenticatedClient(headers);
      _classroomApi = ClassroomApi(client);

      final courses = await _readActiveCourses();
      if (courses.isEmpty) {
        print('No hay cursos activos en Classroom.');
        return;
      }

      String? firstBoardId;
      int totalImported = 0;

      for (final course in courses) {
        if (course.id == null) continue;

        final boardId = await _ensureBoardForCourse(
          userService: userService,
          boardService: boardService,
          course: course,
        );
        if (boardId == null || boardId.isEmpty) continue;

        final courseTasks = await _readCourseTasks(course);
        await taskService.replaceBoardTasks(boardId, courseTasks);

        firstBoardId ??= boardId;
        totalImported += courseTasks.length;
      }

      if (firstBoardId != null) {
        taskService.selectedBoardId = firstBoardId;
      }

      print(
        'Sincronizacion Classroom completa: ${courses.length} tableros y $totalImported tareas importadas.',
      );
    } catch (e) {
      final error = e.toString();
      if (error.contains('status: 403') &&
          error.contains('classroom.googleapis.com')) {
        print(
          'Error 403: la API de Google Classroom esta deshabilitada en el proyecto de Google Cloud usado por la app.',
        );
        print(
          'Activa classroom.googleapis.com en ese proyecto y vuelve a intentar en unos minutos.',
        );
        return;
      }

      print('Error al sincronizar Classroom -> Kanban: $e');
    }
  }

  Future<List<Course>> _readActiveCourses() async {
    if (_classroomApi == null) return [];

    final List<Course> activeCourses = [];
    String? pageToken;

    do {
      final response = await _classroomApi!.courses.list(pageToken: pageToken);
      final courses = response.courses ?? <Course>[];

      for (final course in courses) {
        if (course.id == null) continue;
        if (course.courseState != null && course.courseState != 'ACTIVE') {
          continue;
        }
        activeCourses.add(course);
      }

      pageToken = response.nextPageToken;
    } while (pageToken != null && pageToken.isNotEmpty);

    return activeCourses;
  }

  Future<List<TaskModel>> _readCourseTasks(Course course) async {
    if (_classroomApi == null || course.id == null) return [];

    final List<TaskModel> tasks = [];
    String? pageToken;

    do {
      final response = await _classroomApi!.courses.courseWork.list(
        course.id!,
        pageToken: pageToken,
      );
      final courseWorkList = response.courseWork ?? <CourseWork>[];

      for (final work in courseWorkList) {
        final delivered = await _isDelivered(course.id!, work.id);
        tasks.add(_toTaskModel(course, work, delivered: delivered));
      }

      pageToken = response.nextPageToken;
    } while (pageToken != null && pageToken.isNotEmpty);

    return tasks;
  }

  Future<String?> _ensureBoardForCourse({
    required UserService userService,
    required BoardService boardService,
    required Course course,
  }) async {
    final user = userService.tempUser;
    if (user == null || user.id == null) return null;

    final boardName = _boardNameForCourse(course);

    for (final entry in user.tableros.entries) {
      if (entry.value == boardName) return entry.key;
    }

    final createError = await boardService.createBoard(
      boardName,
      user.id!,
      userService,
    );
    if (createError != null) {
      print('Error creando tablero para ${course.name}: $createError');
      return null;
    }

    for (final entry in user.tableros.entries) {
      if (entry.value == boardName) return entry.key;
    }

    return null;
  }

  String _boardNameForCourse(Course course) {
    final courseName = (course.name ?? 'Sin nombre').trim();
    return '$_boardPrefix$courseName';
  }

  Future<bool> _isDelivered(String courseId, String? courseWorkId) async {
    if (_classroomApi == null || courseWorkId == null || courseWorkId.isEmpty) {
      return false;
    }

    try {
      final response = await _classroomApi!.courses.courseWork.studentSubmissions
          .list(
            courseId,
            courseWorkId,
            userId: 'me',
            pageSize: 1,
          );

      final submissions = response.studentSubmissions ?? <StudentSubmission>[];
      if (submissions.isEmpty) return false;

      final state = submissions.first.state ?? '';
      return state == 'TURNED_IN' || state == 'RETURNED';
    } catch (_) {
      return false;
    }
  }

  TaskModel _toTaskModel(Course course, CourseWork work, {required bool delivered}) {
    final title = (work.title ?? '').trim().isEmpty
        ? 'Tarea sin titulo'
        : work.title!.trim();

    final descriptionParts = <String>[];
    if ((work.description ?? '').trim().isNotEmpty) {
      descriptionParts.add(work.description!.trim());
    }
    if ((work.alternateLink ?? '').trim().isNotEmpty) {
      descriptionParts.add('Classroom: ${work.alternateLink}');
    }

    return TaskModel(
      title: title,
      description: descriptionParts.join('\n'),
      author: course.name ?? 'Google Classroom',
      dueDate: _resolveDueDate(work),
      boardId: 'classroom',
      columnId: delivered ? 'done' : 'todo',
    );
  }

  DateTime _resolveDueDate(CourseWork work) {
    final dueDate = work.dueDate;
    if (dueDate == null) return DateTime.now();

    final dueTime = work.dueTime;
    return DateTime(
      dueDate.year ?? DateTime.now().year,
      dueDate.month ?? 1,
      dueDate.day ?? 1,
      dueTime?.hours ?? 23,
      dueTime?.minutes ?? 59,
      dueTime?.seconds ?? 0,
    );
  }
}
