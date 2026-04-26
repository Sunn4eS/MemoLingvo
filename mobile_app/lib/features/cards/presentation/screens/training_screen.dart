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
        context
            .read<CardRepository>(), // предполагаем, что репозиторий есть выше
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
            return Center(child: Text(l10n.trainig_screen__training_done));
          }

          return CardSwiper(
            numberOfCardsDisplayed: 1,
            //TODO условие если меньше трёх карточек
            threshold: 100,
            cardBuilder: (context, index, _, __) {
              final card = state.cards[index];
              return FlashcardWidget(card: card);
            },
            onSwipe: (previousIndex, currentIndex, direction) {
              context.read<TrainingCubit>().handleSwipe(
                previousIndex,
                direction,
              );
              return true;
            },
            cardsCount: state.cards.length,
          );
        },
      ),
    );
  }
}
