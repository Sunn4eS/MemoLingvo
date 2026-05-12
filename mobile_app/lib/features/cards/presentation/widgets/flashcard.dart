import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';

class FlashcardWidget extends StatefulWidget {
  final db.Card card;
  final double horizontalOffset; // Добавлено: от -1 (влево) до 1 (вправо)

  const FlashcardWidget({
    super.key,
    required this.card,
    this.horizontalOffset = 0, // По умолчанию 0
  });

  @override
  State<StatefulWidget> createState() => FlashcardWidgetState();
}

class FlashcardWidgetState extends State<FlashcardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          final isFrontVisible = angle < (pi / 2);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Stack(
              children: [
                // Основное содержимое карточки
                isFrontVisible
                    ? _buildFrontSide()
                    : Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildBackSide(),
                      ),
                
                // Слой цветового индикатора (Glow)
                _buildSwipeOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Новый метод для отрисовки индикатора свайпа
  Widget _buildSwipeOverlay() {
    if (widget.horizontalOffset == 0) return const SizedBox.shrink();

    final bool isRight = widget.horizontalOffset > 0;
    final double opacity = (widget.horizontalOffset.abs() * 0.8).clamp(0.0, 0.8);
    final Color overlayColor = isRight ? Colors.green : Colors.red;
    final IconData icon = isRight ? Icons.check_circle_outline : Icons.highlight_off;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: overlayColor.withOpacity(opacity),
      ),
      child: Center(
        child: Opacity(
          opacity: (widget.horizontalOffset.abs() * 2).clamp(0.0, 1.0),
          child: Icon(
            icon,
            size: 100,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFrontSide() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero, // Убираем дефолтные отступы для чистоты анимации
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: Theme.of(context).cardColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.card.word,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (widget.card.transcription != null && widget.card.transcription!.isNotEmpty)
                Text(
                  "[${widget.card.transcription}]",
                  style: TextStyle(
                    fontSize: 22,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 40),
              Icon(Icons.touch_app, size: 24, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(
                l10n.flash_card__tap_to_flip,
                style: TextStyle(color: Colors.grey.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackSide() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.card.translation,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (widget.card.meaning != null && widget.card.meaning!.isNotEmpty) ...[
                  const Divider(),
                  Text(
                    widget.card.meaning!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.card.examples != null && widget.card.examples!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: widget.card.examples!
                          .map((example) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "• $example",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}