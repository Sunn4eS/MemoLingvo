import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class TrainingState {
  final List<Card> cards;
  final int currentIndex;
  final bool isFinished;

  TrainingState({
    required this.cards,
    this.currentIndex = 0,
    this.isFinished = false,
  });
  TrainingState copyWith({
    List<Card>? cards,
    int? currentIndex,
    bool? isFinished,
  }) {
    return TrainingState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class TrainingCubit extends Cubit<TrainingState> {
  final CardRepository _repository;
  final String deckId;

  TrainingCubit(this._repository, this.deckId)
    : super(TrainingState(cards: [])) {
    _init();
  }

  void _init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;

    final serverId = await _repository.getServerUserId(user!.email!);
    if (serverId == null) return;

    final cards = await _repository.getDueCards(deckId, serverId);

    emit(
      TrainingState(cards: cards, isFinished: cards.isEmpty, currentIndex: 0),
    );
  }

  void handleSwipe(int index, CardSwiperDirection direction) async {
    if (state.cards.isEmpty || index >= state.cards.length) return;

    final card = state.cards[index];
    final user = FirebaseAuth.instance.currentUser;
    final serverId = await _repository.getServerUserId(user!.email!);

    if (direction == CardSwiperDirection.right) {
      if (index >= state.cards.length - 1) {
        emit(state.copyWith(isFinished: true));
      }
      await _repository.updateCardProgress(card.id, serverId!, 5);
    } else {
      await _repository.updateCardProgress(card.id, serverId!, 1);

      final updatedCards = List<Card>.from(state.cards);
      updatedCards.add(card);
      emit(state.copyWith(cards: updatedCards));
    }

    if (index >= state.cards.length - 1) {
      emit(state.copyWith(isFinished: true));
    }
  }
}
