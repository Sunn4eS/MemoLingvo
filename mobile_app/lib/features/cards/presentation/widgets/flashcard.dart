import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';

class FlashcardWidget extends StatelessWidget {
  final db.Card card;
  final int horizontalThreshold;

  const FlashcardWidget({
    required this.card,
    required this.horizontalThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final double opacity = (horizontalThreshold.abs() / 100).clamp(0.0, 0.8);
    final l10n = AppLocalizations.of(context)!;
    Color overlayColor = Colors.transparent;
    IconData? overlayIcon;

    if (horizontalThreshold > 5) {
      overlayColor = Colors.green.withOpacity(opacity);
      overlayIcon = Icons.check_circle_outline;
    } else if (horizontalThreshold < -5) {
      overlayColor = Colors.red.withOpacity(opacity);
      overlayIcon = Icons.cancel_outlined;
    }

    return FlipCard(
      fill: Fill.fillBack,
      direction: FlipDirection.HORIZONTAL,
      front: _buildSide(
        title: card.word,
        subtitle: card.transcription,
        color: Colors.white,
        overlayColor: overlayColor,
        overlayIcon: overlayIcon,
      ),
      back: _buildSide(
        title: card.translation,
        subtitle: "${l10n.add_card_screen__examples}: ${card.examples?.join(', ') ?? ''}",
        color: Colors.blue.shade50,
      ),
    );
  }

  Widget _buildSide({
    required String title,
    String? subtitle,
    required Color color,
    Color overlayColor = Colors.transparent,
    IconData? overlayIcon,
  }) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Stack(
        children: [
          Container(
            color: color,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: overlayColor,
            child: Center(
              child: overlayIcon != null
                  ? Icon(overlayIcon, color: Colors.white, size: 80)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
