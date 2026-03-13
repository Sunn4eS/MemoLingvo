import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';

class TrainingState {
  final List<Card> cards;
  final int currentIndex;
  final bool isFinished;

  TrainingState({
    required this.cards,
    this.currentIndex = 0,
    this.isFinished = false,
  });
}

class TrainingCubit extends Cubit<TrainingState> {
  final CardRepository _repository;
  final int deckId;

  TrainingCubit(this._repository, this.deckId)
    : super(TrainingState(cards: [])) {
    _loadCards();
  }

  void _loadCards() async {
    final cards = await _repository.watchCards(deckId).first;
    emit(TrainingState(cards: cards));
  }

  void handleSwipe(int index, CardSwiperDirection direction) {
    final card = state.cards[index];

    if (direction == CardSwiperDirection.right) {
      _repository.updateStatus(card.id, LearningStatus.learning);
    } else if (direction == CardSwiperDirection.left) {
      _repository.updateStatus(card.id, LearningStatus.newCard);
    }

    if (index == state.cards.length - 1) {
      emit(TrainingState(cards: state.cards, isFinished: true));
    }
  }
}
