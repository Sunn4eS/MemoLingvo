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
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isFinished) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  const Icon(Icons.emoji_events, size: 80, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    l10n.trainig_screen__training_done,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
          
          return SafeArea(
            child: Stack(
              children:[
                // Визуальный фон для подсказки при свайпе
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children:[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              bottomLeft: Radius.circular(25),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(32),
                          child: const Icon(Icons.refresh, color: Colors.red, size: 48),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.all(32),
                          child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Сам механизм свайпа
                CardSwiper(
                  // Разрешаем только свайпы влево и вправо
                  allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
                  numberOfCardsDisplayed: state.cards.length > 1 ? 2 : 1,
                  padding: const EdgeInsets.all(24),
                  cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                    final card = state.cards[index];
                    return FlashcardWidget(
                      key: ValueKey('${card.id}_$index'), // Уникальный ключ
                      card: card
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
              ],
            ),
          );
        },
      ),
    );
  }
}