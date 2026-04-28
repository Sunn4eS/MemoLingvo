import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/features/decks/data/repositories/deck_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:memo_lingvo/core/utils.dart';

class DeckCubit extends Cubit<List<DeckWithCount>> {
  final DeckRepository _repository;
  StreamSubscription? _dbSubscription;
  StreamSubscription? _authSubscription;

  // В файле: lib/features/decks/logic/deck_cubit.dart

  DeckCubit(this._repository) : super([]) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null && user.email != null) {
        
        // Даем небольшую задержку, чтобы AuthCubit успел записать юзера в базу при первом входе
        await Future.delayed(const Duration(milliseconds: 500));
        
        final serverId = await _repository.getServerUserId(user.email!);
        
        if (serverId != null) {
          _listenToDecks(serverId); 
        } else {
          print("❌ Ошибка DeckCubit: Не удалось найти serverId в локальной БД");
        }
      } else {
        _dbSubscription?.cancel();
        emit([]); 
      }
    });
  }

  Future<void> importDeckByCode(String code) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      final serverId = await _repository.getServerUserId(email);
      if (serverId != null) {
        await _repository.importDeck(code, serverId);
      }
    }
  }
  
  void _listenToDecks(String userId) {
    _dbSubscription?.cancel();
    // Слушаем базу данных с правильным ID пользователя (C# GUID)
    _dbSubscription = _repository.watchDecksWithCount(userId).listen((items) {
      emit(items);
    });
  }

  Future<void> updateDeck(Deck deck) async {
    await _repository.updateDeck(deck);
  }

  Future<void> addDeck(String title, String? description) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      final serverId = await _repository.getServerUserId(email); 
      if (serverId != null) {
        await _repository.createDeck(title, description, serverId); 
      }
    }
  }

  Future<void> deleteDeck(String id) async {
    await _repository.deleteDeck(id);
  }

  @override
  Future<void> close() {
    _dbSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}