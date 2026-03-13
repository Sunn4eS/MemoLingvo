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
  String get deck_card__show_action_menu_edit_title => 'Редактировать название';

  @override
  String get deck_card__show_action_menu_delete_deck => 'Удалить колоду';

  @override
  String get decks_view__show_edit_deck_dialog_edit_deck =>
      'Редактировать колоду';

  @override
  String get decks_view__show_edit_deck_dialog_title_label => 'Название';

  @override
  String get decks_view__show_edit_deck_dialog_hint_title =>
      'Введите название колоды';

  @override
  String get decks_view__show_edit_deck_dialog_description_label =>
      'Описание (необязательно)';

  @override
  String get decks_view__show_edit_deck_dialog_hint_description =>
      'Введите описание';

  @override
  String get decks_view__show_edit_deck_dialog_save => 'Сохранить';

  @override
  String get decks_view__show_edit_deck_dialog_cancel => 'Отмена';

  @override
  String get add_card_screen__new_card => 'Добавить карточку';

  @override
  String get add_card_screen__word => 'Слово';

  @override
  String get add_card_screen__translation => 'Перевод';

  @override
  String get add_card_screen__transcription => 'Транскрибция';

  @override
  String get add_card_screen__meaning => 'Значение/Подсказка';

  @override
  String get add_card_screen__examples => 'Примеры использоавния';

  @override
  String get add_card_screen__add_example => 'Добавить';

  @override
  String get add_card_screen__add_example_hint => 'Текст примера';

  @override
  String get add_card_screen__required_field => 'Обязательное поле';

  @override
  String get manage_deck_screen__cards_list_title => 'Список карточек';

  @override
  String get manage_deck_screen__no_cards => 'Нет карт в колоде';
}
