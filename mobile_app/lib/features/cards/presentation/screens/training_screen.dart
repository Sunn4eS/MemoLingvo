import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/cards/logic/training_cubit.dart';
import 'package:memo_lingvo/features/cards/presentation/widgets/flashcard.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';

class TrainingScreen extends StatelessWidget {
  final String deckId;
  const TrainingScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrainingCubit(
        context.read<CardRepository>(),
        deckId,
      ),
      child: const _TrainingScreenContent(),
    );
  }
}

class _TrainingScreenContent extends StatelessWidget {
  const _TrainingScreenContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainig_screen__training)),
      body: BlocBuilder<TrainingCubit, TrainingState>(
        builder: (context, state) {
          if (state.cards.isEmpty) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            "Все карточки в этой колоде выучены!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Возвращайтесь позже, когда придет время для повторения.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Назад к колодам"),
          )
        ],
      ),
    ),
  );
}
          if (state.isFinished) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 80, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    l10n.trainig_screen__training_done,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Назад к колодам"),
                  )
                ],
              ),
            );
          }
          
          return SafeArea(
            child: CardSwiper(
              // Настройки анимации
              duration: const Duration(milliseconds: 300),
              allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
              numberOfCardsDisplayed: state.cards.length > 1 ? 2 : 1,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              
              // Основной строитель карточки
              cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                final card = state.cards[index];
                
                // Передаем horizontalOffsetPercentage (от -100 до 100 в этом пакете обычно, 
                // поэтому делим на 100 для получения значения от -1.0 до 1.0)
                final double offset = horizontalOffsetPercentage / 100;

                return FlashcardWidget(
                  key: ValueKey('${card.id}_$index'),
                  card: card,
                  horizontalOffset: offset, // Прокидываем смещение для анимации
                );
              },
              
              onSwipe: (previousIndex, currentIndex, direction) {
                context.read<TrainingCubit>().handleSwipe(
                  previousIndex,
                  direction,
                );
                return true;
              },
              cardsCount: state.cards.length,
            ),
          );
        },
      ),
    );
  }
}