import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';

class FlashcardWidget extends StatefulWidget {
  final db.Card card;

  const FlashcardWidget({required this.card});
  @override
  State<StatefulWidget> createState() => FlashcardWidgetState();
}

class FlashcardWidgetState extends State<FlashcardWidget> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => setState(() => _showTranslation = !_showTranslation),
      child: material.Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: _showTranslation ? Colors.blue.shade50 : Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _showTranslation ? widget.card.translation : widget.card.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!_showTranslation && widget.card.transcription != null)
                  Text(
                    "[${widget.card.transcription}]",
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                const SizedBox(height: 20),
                Text(
                  l10n.flash_card__tap_to_flip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
