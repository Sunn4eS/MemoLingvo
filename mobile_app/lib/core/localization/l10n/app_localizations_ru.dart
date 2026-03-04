// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'MemoLingvo';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get login => 'Войти';

  @override
  String get password => 'Password';

  @override
  String get welcome_screen_startLearning => 'Начать обучение (Регистрация)';

  @override
  String get register_screen_register => 'Регистрация';

  @override
  String get register_screen_email => 'Электронная почта';

  @override
  String get register_screen_password => 'Пароль';

  @override
  String get register_screen_create_account => 'Создать аккаунт';
}
