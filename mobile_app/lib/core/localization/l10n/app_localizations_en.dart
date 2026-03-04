// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MemoLingvo';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Log in';

  @override
  String get password => 'Password';

  @override
  String get welcome_screen_startLearning => 'Start learning (register)';

  @override
  String get register_screen_register => 'Register';

  @override
  String get register_screen_email => 'Email';

  @override
  String get register_screen_password => 'Password';

  @override
  String get register_screen_create_account => 'Create account';

  @override
  String get settings_screen_title => 'Settings';

  @override
  String get settings_screen_change_language => 'Change language';

  @override
  String get settings_screen_dark_mode => 'Dark theme';

  @override
  String get settings_screen_logout => 'Log out';
}
