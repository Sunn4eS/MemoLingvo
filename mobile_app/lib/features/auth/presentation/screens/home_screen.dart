import 'package:flutter/material.dart';
import 'package:lingo_cards/core/localization/l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
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
                AppLocalizations.of(context)!.home_screen_startLearning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
