import 'package:flutter/material.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "MemoLingvo",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text(
                AppLocalizations.of(context)!.welcome_screen_register,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text(AppLocalizations.of(context)!.welcome_screen_login),
            ),
          ],
        ),
      ),
    );
  }
}
