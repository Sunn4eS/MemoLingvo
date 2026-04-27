import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:memo_lingvo/core/database/app_database.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    // Иконка для Android (должна быть в папке android/app/src/main/res/drawable/ic_launcher.png или mipmap)
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(settings: settings);

    // Запрос разрешений для Android 13+
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  Future<void> scheduleWordOfTheDay(AppDatabase db) async {
  // 1. Отменяем старые уведомления
  await _notificationsPlugin.cancelAll();

  // 2. Достаем все неудаленные карточки
  final cards = await (db.select(db.cards)..where((t) => t.isDeleted.equals(false))).get();
  if (cards.isEmpty) return;

  // 3. Перемешиваем и берем максимум 7 слов (на неделю вперед)
  cards.shuffle();
  final wordsToSchedule = cards.take(7).toList();

  // 4. Планируем уведомления
  for (int i = 0; i < wordsToSchedule.length; i++) {
    final card = wordsToSchedule[i];

    // Назначаем на завтрашний и последующие дни, в 12:00 дня
    final scheduledDate = DateTime.now().add(Duration(days: i + 1));
    final tzDate = tz.TZDateTime.local(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      12,
      0,
    );

    await _notificationsPlugin.zonedSchedule(
      id: i,
      title: 'Слово дня: ${card.word}',
      body: 'Знаете как переводится? Нажмите, чтобы проверить!',
      scheduledDate: tzDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'word_of_day_channel',
          'Слово дня',
          channelDescription: 'Ежедневные уведомления со словами',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
}