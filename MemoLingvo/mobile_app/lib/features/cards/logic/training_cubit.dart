import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Обязательно импортируем Firebase
//import 'package:memo_lingvo/core/utils.dart';

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
  final String deckId; // ID теперь String (UUID)

  TrainingCubit(this._repository, this.deckId)
    : super(TrainingState(cards: [])) {
    _loadCards();
  }

  void _loadCards() async {
    final cards = await _repository.watchCards(deckId).first;
    emit(TrainingState(cards: cards));
  }

  // В файле: lib/features/cards/logic/training_cubit.dart

  void handleSwipe(int index, CardSwiperDirection direction) async {
    if (state.cards.isEmpty) return;
    
    final card = state.cards[index];
    final firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser == null || firebaseUser.email == null) {
      print("Ошибка: Пользователь не авторизован!");
      return;
    }

    int quality = (direction == CardSwiperDirection.right) ? 5 : 1;

    // Достаем СЕРВЕРНЫЙ ID
    final serverId = await _repository.getServerUserId(firebaseUser.email!);
    if (serverId != null) {
      // Сохраняем прогресс локально с флагом isDirty = 1 (как просил бэкендер)
      _repository.updateCardProgress(card.id, serverId, quality);
    }

    if (index == state.cards.length - 1) {
      emit(TrainingState(cards: state.cards, isFinished: true));
    } else {
      emit(TrainingState(cards: state.cards, currentIndex: index + 1, isFinished: false));
    }
  }
}