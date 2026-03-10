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
  String get welcome_screen_register => 'Start learning (register)';

  @override
  String get welcome_screen_login => 'Login';

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

  @override
  String get login_screen_title => 'Login';

  @override
  String get login_screen_no_account => 'No account? Create';

  @override
  String get decks_view_no_decks =>
      'There aren\'t any decks here. Create first!';

  @override
  String get decks_view__show_add_deck_dialog_new_deck => 'New deck';

  @override
  String get decks_view__show_add_deck_dialog_hint_title =>
      'Title (example, Hobbies)';

  @override
  String get decks_view__show_add_deck_dialog_cancel => 'Cancel';

  @override
  String get decks_view__show_add_deck_dialog_create => 'Create';

  @override
  String get deck_card_show_action_menu_edit_title => 'Edit title';

  @override
  String get deck_card_show_action_menu_delete_deck => 'Delete deck';
}
