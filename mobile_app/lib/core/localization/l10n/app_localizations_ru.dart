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
  String get welcome_screen_register => 'Начать обучение (Регистрация)';

  @override
  String get welcome_screen_login => 'Войти';

  @override
  String get register_screen_register => 'Регистрация';

  @override
  String get register_screen_email => 'Электронная почта';

  @override
  String get register_screen_password => 'Пароль';

  @override
  String get register_screen_create_account => 'Создать аккаунт';

  @override
  String get settings_screen_title => 'Настройки';

  @override
  String get settings_screen_change_language => 'Изменить язык';

  @override
  String get settings_screen_dark_mode => 'Темная тема';

  @override
  String get settings_screen_logout => 'Выйти из аккаунта';

  @override
  String get login_screen_title => 'Войти';

  @override
  String get login_screen_no_account => 'Нет аккаунта? Создать';

  @override
  String get decks_view_no_decks => 'Здесь пока нет колод. Создайте первую!';

  @override
  String get decks_view__show_add_deck_dialog_new_deck => 'Новая колода';

  @override
  String get decks_view__show_add_deck_dialog_hint_title =>
      'Название (например, Хобби)';

  @override
  String get decks_view__show_add_deck_dialog_cancel => 'Отмена';

  @override
  String get decks_view__show_add_deck_dialog_create => 'Создать';

  @override
  String get deck_card_show_action_menu_edit_title => 'Редактировать название';

  @override
  String get deck_card_show_action_menu_delete_deck => 'Удалить колоду';
}
