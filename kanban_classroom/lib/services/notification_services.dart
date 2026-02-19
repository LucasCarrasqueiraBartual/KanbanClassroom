import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

// gestiona las alertas locales en el dispositivo.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.localizedName!.name));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC')); 
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

      await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print("Notificacion tocada: ${details.payload}");
      },
    );    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Crea un recordatorio para el futuro.
  static Future<void> programarAvisoTarea({
    required int id,
    required String titulo,
    required DateTime fechaEntrega,
  }) async {
    final avisoDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));


    if (avisoDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notificationsPlugin.zonedSchedule(
      id: id, 
      title: '¡Atencion!', 
      body: 'La tarea "$titulo" vence pronto.', 
      scheduledDate: avisoDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'kanban_alerts',
          'Alertas de Tareas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  static Future<void> cancelarAvisoTarea(int id) async {
    await _notificationsPlugin.cancel(id: id);
    print("Notificacion $id cancelada");
  }

  static Future<void> cancelarTodosLosAvisos() async {
    await _notificationsPlugin.cancelAll();
  }
}