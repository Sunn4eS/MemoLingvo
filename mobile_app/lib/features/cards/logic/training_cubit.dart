import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final String deckId;

  TrainingCubit(this._repository, this.deckId)
    : super(TrainingState(cards:[])) {
    _loadCards();
  }

  void _loadCards() async {
    // Берем карточки из базы
    final cards = await _repository.watchCards(deckId).first;
    emit(TrainingState(cards: cards));
  }

  void handleSwipe(int index, CardSwiperDirection direction) async {
    if (state.cards.isEmpty) return;
    
    final card = state.cards[index];
    final firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser == null || firebaseUser.email == null) {
      print("Ошибка: Пользователь не авторизован!");
      return;
    }

    // Качество изучения: 5 для свайпа вправо (хорошо), 1 для влево (плохо)
    int quality = (direction == CardSwiperDirection.right) ? 5 : 1;
    final serverId = await _repository.getServerUserId(firebaseUser.email!);
    
    if (serverId != null) {
      // Сохраняем прогресс в БД
      _repository.updateCardProgress(card.id, serverId, quality);
    }

    // Создаем изменяемую копию списка
    List<Card> updatedCards = List.from(state.cards);

    // Если карточка изучена плохо (свайп влево) - добавляем ее в конец списка
    if (direction == CardSwiperDirection.left) {
      updatedCards.add(card);
    }

    // Проверяем, не закончились ли карточки с учетом возможного пополнения
    if (index >= updatedCards.length - 1) {
      emit(TrainingState(cards: updatedCards, isFinished: true));
    } else {
      emit(TrainingState(
        cards: updatedCards, 
        currentIndex: index + 1, 
        isFinished: false
      ));
    }
  }
}