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
  String get register => 'Регистрация';

  @override
  String get email => 'Эл. почта';

  @override
  String get password => 'Пароль';

  @override
  String get home_screen_startLearning => 'Начать обучение (Регистрация)';
}
