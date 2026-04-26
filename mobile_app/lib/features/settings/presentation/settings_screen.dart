import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/core/localization/locale_cubit.dart';
import 'package:memo_lingvo/features/auth/logic/auth_cubit.dart';
import 'package:memo_lingvo/core/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final currentLocale = context.watch<LocaleCubit>().state;

    String getCurrentLanguageName() {
      switch (currentLocale.languageCode) {
        case 'en':
          return 'English';
        case 'ru':
          return 'Русский';
        default:
          return 'Русский';
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_screen_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settings_screen_change_language),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getCurrentLanguageName(),
                  style: const TextStyle(color: Colors.grey),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () => _showLanguagePicker(context),
          ),

          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: Text(l10n.settings_screen_dark_mode),
                value: mode == ThemeMode.dark,
                onChanged: (bool value) {
                  context.read<ThemeCubit>().toggleTheme(value);
                },
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              l10n.settings_screen_logout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              context.read<AuthCubit>().logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/welcome', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: const Text("Русский"),
            onTap: () {
              context.read<LocaleCubit>().setLocale('ru');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("English"),
            onTap: () {
              context.read<LocaleCubit>().setLocale('en');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

//TODO showlangugaepicker
