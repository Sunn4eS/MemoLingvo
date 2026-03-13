import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MemoLingvo'**
  String get appTitle;

  /// No description provided for @welcome_screen_register.
  ///
  /// In en, this message translates to:
  /// **'Start learning (register)'**
  String get welcome_screen_register;

  /// No description provided for @welcome_screen_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get welcome_screen_login;

  /// No description provided for @register_screen_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register_screen_register;

  /// No description provided for @register_screen_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get register_screen_email;

  /// No description provided for @register_screen_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get register_screen_password;

  /// No description provided for @register_screen_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register_screen_create_account;

  /// No description provided for @settings_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_screen_title;

  /// No description provided for @settings_screen_change_language.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get settings_screen_change_language;

  /// No description provided for @settings_screen_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get settings_screen_dark_mode;

  /// No description provided for @settings_screen_logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settings_screen_logout;

  /// No description provided for @login_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_screen_title;

  /// No description provided for @login_screen_no_account.
  ///
  /// In en, this message translates to:
  /// **'No account? Create'**
  String get login_screen_no_account;

  /// No description provided for @decks_view_no_decks.
  ///
  /// In en, this message translates to:
  /// **'There aren\'t any decks here. Create first!'**
  String get decks_view_no_decks;

  /// No description provided for @decks_view__show_add_deck_dialog_new_deck.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get decks_view__show_add_deck_dialog_new_deck;

  /// No description provided for @decks_view__show_add_deck_dialog_hint_title.
  ///
  /// In en, this message translates to:
  /// **'Title (example, Hobbies)'**
  String get decks_view__show_add_deck_dialog_hint_title;

  /// No description provided for @decks_view__show_add_deck_dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get decks_view__show_add_deck_dialog_cancel;

  /// No description provided for @decks_view__show_add_deck_dialog_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get decks_view__show_add_deck_dialog_create;

  /// No description provided for @deck_card__show_action_menu_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit title'**
  String get deck_card__show_action_menu_edit_title;

  /// No description provided for @deck_card__show_action_menu_delete_deck.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get deck_card__show_action_menu_delete_deck;

  /// No description provided for @decks_view__show_edit_deck_dialog_edit_deck.
  ///
  /// In en, this message translates to:
  /// **'Edit deck'**
  String get decks_view__show_edit_deck_dialog_edit_deck;

  /// No description provided for @decks_view__show_edit_deck_dialog_title_label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get decks_view__show_edit_deck_dialog_title_label;

  /// No description provided for @decks_view__show_edit_deck_dialog_hint_title.
  ///
  /// In en, this message translates to:
  /// **'Enter deck title'**
  String get decks_view__show_edit_deck_dialog_hint_title;

  /// No description provided for @decks_view__show_edit_deck_dialog_description_label.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get decks_view__show_edit_deck_dialog_description_label;

  /// No description provided for @decks_view__show_edit_deck_dialog_hint_description.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get decks_view__show_edit_deck_dialog_hint_description;

  /// No description provided for @decks_view__show_edit_deck_dialog_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get decks_view__show_edit_deck_dialog_save;

  /// No description provided for @decks_view__show_edit_deck_dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get decks_view__show_edit_deck_dialog_cancel;

  /// No description provided for @add_card_screen__new_card.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get add_card_screen__new_card;

  /// No description provided for @add_card_screen__word.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get add_card_screen__word;

  /// No description provided for @add_card_screen__translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get add_card_screen__translation;

  /// No description provided for @add_card_screen__transcription.
  ///
  /// In en, this message translates to:
  /// **'Transcription'**
  String get add_card_screen__transcription;

  /// No description provided for @add_card_screen__meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning/Hint'**
  String get add_card_screen__meaning;

  /// No description provided for @add_card_screen__examples.
  ///
  /// In en, this message translates to:
  /// **'Examples of using'**
  String get add_card_screen__examples;

  /// No description provided for @add_card_screen__add_example.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add_card_screen__add_example;

  /// No description provided for @add_card_screen__add_example_hint.
  ///
  /// In en, this message translates to:
  /// **'Example text'**
  String get add_card_screen__add_example_hint;

  /// No description provided for @add_card_screen__required_field.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get add_card_screen__required_field;

  /// No description provided for @manage_deck_screen__cards_list_title.
  ///
  /// In en, this message translates to:
  /// **'Cards list'**
  String get manage_deck_screen__cards_list_title;

  /// No description provided for @manage_deck_screen__no_cards.
  ///
  /// In en, this message translates to:
  /// **'No cards in deck'**
  String get manage_deck_screen__no_cards;

  /// No description provided for @trainig_screen__training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get trainig_screen__training;

  /// No description provided for @trainig_screen__training_done.
  ///
  /// In en, this message translates to:
  /// **'Excellent! All words complete.'**
  String get trainig_screen__training_done;

  /// No description provided for @flash_card__tap_to_flip.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get flash_card__tap_to_flip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
