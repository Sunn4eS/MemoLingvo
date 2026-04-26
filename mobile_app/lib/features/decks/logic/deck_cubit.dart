import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/features/decks/data/repositories/deck_repository.dart';

class DeckCubit extends Cubit<List<DeckWithCount>> {
  final DeckRepository _repository;
  StreamSubscription? _subscription;

  DeckCubit(this._repository) : super([]) {
    _init();
  }

  void _init() {
    _subscription?.cancel();

    _subscription = _repository.watchDecksWithCount().listen((items) {
      emit(items);
    });
  }
  
  // Future<void> updateDeck(int id, String newTitle) async {
  //   await _repository.updateDeckTitle(id, newTitle);
  // }

  Future<void> updateDeck(Deck deck) async {
    await _repository.updateDeck(deck);
 // emit(await _r.watchDecksWithCardCount().first); // или обновить состояние через Stream
  }

  Future<void> addDeck(String title, String? description) async {
    await _repository.createDeck(title, description);
  }

  Future<void> deleteDeck(int id) async {
    await _repository.deleteDeck(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
