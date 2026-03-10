import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/features/decks/data/repositories/deck_repository.dart';

class DeckCubit extends Cubit<List<Deck>> {
  final DeckRepository _repository;

  DeckCubit(this._repository) : super([]) {
    _init();
  }

  void _init() {
    _repository.watchDecks().listen((decks) {
      emit(decks);
    });
  }

  Future<void> addDeck(String title, String? description) async {
    await _repository.createDeck(title, description);
  }

  Future<void> deleteDeck(int id) async {
    await _repository.deleteDeck(id);
  }

}
