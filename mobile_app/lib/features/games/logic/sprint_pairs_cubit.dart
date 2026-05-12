import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';

class Pair {
  final String cardId;
  final String word;
  final String translation;
  const Pair(this.cardId, this.word, this.translation);
}

class SprintPairsState {
  final List<Pair> remainingPairs;
  final List<Pair> shuffledLeft;
  final List<Pair> shuffledRight;
  final String? selectedLeftId;
  final String? selectedRightId;
  final int playerScore;
  final int pairsFound;
  final int totalPairs;
  final bool isFinished;
  final int totalTimeLeft;

  const SprintPairsState({
    required this.remainingPairs,
    required this.shuffledLeft,
    required this.shuffledRight,
    this.selectedLeftId,
    this.selectedRightId,
    required this.playerScore,
    required this.pairsFound,
    required this.totalPairs,
    required this.isFinished,
    required this.totalTimeLeft,
  });

  factory SprintPairsState.initial(List<Pair> pairs, int timePerGame) {
    final left = List<Pair>.from(pairs)..shuffle();
    final right = List<Pair>.from(pairs)..shuffle();
    return SprintPairsState(
      remainingPairs: List<Pair>.from(pairs),
      shuffledLeft: left,
      shuffledRight: right,
      playerScore: 0,
      pairsFound: 0,
      totalPairs: pairs.length,
      isFinished: false,
      totalTimeLeft: timePerGame,
    );
  }

  SprintPairsState copyWith({
    List<Pair>? remainingPairs,
    List<Pair>? shuffledLeft,
    List<Pair>? shuffledRight,
    String? selectedLeftId,
    String? selectedRightId,
    int? playerScore,
    int? pairsFound,
    int? totalPairs,
    bool? isFinished,
    int? totalTimeLeft,
  }) {
    return SprintPairsState(
      remainingPairs: remainingPairs ?? this.remainingPairs,
      shuffledLeft: shuffledLeft ?? this.shuffledLeft,
      shuffledRight: shuffledRight ?? this.shuffledRight,
      selectedLeftId: selectedLeftId ?? this.selectedLeftId,
      selectedRightId: selectedRightId ?? this.selectedRightId,
      playerScore: playerScore ?? this.playerScore,
      pairsFound: pairsFound ?? this.pairsFound,
      totalPairs: totalPairs ?? this.totalPairs,
      isFinished: isFinished ?? this.isFinished,
      totalTimeLeft: totalTimeLeft ?? this.totalTimeLeft,
    );
  }
}

class SprintPairsCubit extends Cubit<SprintPairsState> {
  final GameRepository _repository;
  final String email;
  Timer? _gameTimer;
  DateTime? _sessionStartTime;

  SprintPairsCubit(this._repository, this.email, List<db.Card> cards)
    : super(
        SprintPairsState.initial(
          cards.map((c) => Pair(c.id, c.word, c.translation)).toList(),
          90,
        ),
      ) {
    _sessionStartTime = DateTime.now();
    _startGameTimer();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isFinished) return;
      if (state.totalTimeLeft <= 1) {
        _finishGame();
      } else {
        emit(state.copyWith(totalTimeLeft: state.totalTimeLeft - 1));
      }
    });
  }

  void selectLeft(String cardId) {
    if (state.selectedLeftId == cardId) {
      emit(state.copyWith(selectedLeftId: null));
    } else {
      emit(state.copyWith(selectedLeftId: cardId));
      _checkMatch();
    }
  }

  void selectRight(String cardId) {
    if (state.selectedRightId == cardId) {
      emit(state.copyWith(selectedRightId: null));
    } else {
      emit(state.copyWith(selectedRightId: cardId));
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (state.selectedLeftId != null && state.selectedRightId != null) {
      final leftId = state.selectedLeftId!;
      final rightId = state.selectedRightId!;
      if (leftId == rightId) {
        final newRemaining = state.remainingPairs
            .where((p) => p.cardId != leftId)
            .toList();

        final newLeft = List<Pair>.from(newRemaining)..shuffle();
        final newRight = List<Pair>.from(newRemaining)..shuffle();

        final roundScore = 50 + state.totalTimeLeft;
        final newScore = state.playerScore + roundScore;
        final newPairsFound = state.pairsFound + 1;
        emit(
          state.copyWith(
            remainingPairs: newRemaining,
            shuffledLeft: newLeft,
            shuffledRight: newRight,
            playerScore: newScore,
            pairsFound: newPairsFound,
            selectedLeftId: null,
            selectedRightId: null,
          ),
        );
        if (newRemaining.isEmpty) {
          _finishGame();
        }
      } else {
        emit(
          state.copyWith(
            selectedLeftId: null,
            selectedRightId: null,
            playerScore: state.playerScore - 10,
          ),
        );
      }
    }
  }

  Future<void> _finishGame() async {
    if (state.isFinished) return;
    _gameTimer?.cancel();

    final totalTime = DateTime.now().difference(_sessionStartTime!).inSeconds;
    final accuracy = state.totalPairs > 0
        ? ((state.pairsFound / state.totalPairs) * 100).toInt()
        : 0;

    final serverUserId = await _repository.database.getServerUserId(email);
    if (serverUserId != null) {
      await _repository.saveGameResult(
        userId: serverUserId,
        gameType: 'sprint_pairs',
        result: 'completed',
        score: state.playerScore,
        timeTakenSeconds: totalTime,
        accuracyPercent: accuracy,
      );
    }

    emit(state.copyWith(isFinished: true));
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    return super.close();
  }
}
