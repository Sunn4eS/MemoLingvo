import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';

class Pair {
  final String word;
  final String translation;
  const Pair(this.word, this.translation);
}

class SprintPairsState {
  final List<String> leftColumn;
  final List<String> rightColumn;
  final String? selectedLeft;
  final String? selectedRight;
  final int playerScore;
  final int pairsFound;
  final int totalPairs;
  final bool isFinished;
  final int timeLeft;

  const SprintPairsState({
    required this.leftColumn,
    required this.rightColumn,
    this.selectedLeft,
    this.selectedRight,
    required this.playerScore,
    required this.pairsFound,
    required this.totalPairs,
    required this.isFinished,
    required this.timeLeft,
  });

  factory SprintPairsState.initial(List<Pair> pairs, int timePerGame) {
    final words = pairs.map((p) => p.word).toList();
    final translations = pairs.map((p) => p.translation).toList()..shuffle();
    return SprintPairsState(
      leftColumn: words,
      rightColumn: translations,
      playerScore: 0,
      pairsFound: 0,
      totalPairs: pairs.length,
      isFinished: false,
      timeLeft: timePerGame,
    );
  }

  SprintPairsState copyWith({
    List<String>? leftColumn,
    List<String>? rightColumn,
    String? selectedLeft,
    String? selectedRight,
    int? playerScore,
    int? pairsFound,
    int? totalPairs,
    bool? isFinished,
    int? timeLeft,
  }) {
    return SprintPairsState(
      leftColumn: leftColumn ?? this.leftColumn,
      rightColumn: rightColumn ?? this.rightColumn,
      selectedLeft: selectedLeft ?? this.selectedLeft,
      selectedRight: selectedRight ?? this.selectedRight,
      playerScore: playerScore ?? this.playerScore,
      pairsFound: pairsFound ?? this.pairsFound,
      totalPairs: totalPairs ?? this.totalPairs,
      isFinished: isFinished ?? this.isFinished,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

class SprintPairsCubit extends Cubit<SprintPairsState> {
  final GameRepository _repository;
  final String email;
  final List<Pair> _originalPairs;
  Timer? _timer;
  DateTime? _sessionStartTime;

  SprintPairsCubit(this._repository, this.email, List<db.Card> cards)
    : _originalPairs = cards.map((c) => Pair(c.word, c.translation)).toList(),
      super(
        SprintPairsState.initial(
          cards.map((c) => Pair(c.word, c.translation)).toList(),
          60,
        ),
      ) {
    _sessionStartTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft <= 1) {
        _finishGame();
      } else {
        emit(state.copyWith(timeLeft: state.timeLeft - 1));
      }
    });
  }

  void selectLeft(String word) {
    if (state.selectedLeft == word) {
      emit(state.copyWith(selectedLeft: null));
    } else {
      emit(state.copyWith(selectedLeft: word));
      _checkMatch();
    }
  }

  void selectRight(String translation) {
    if (state.selectedRight == translation) {
      emit(state.copyWith(selectedRight: null));
    } else {
      emit(state.copyWith(selectedRight: translation));
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (state.selectedLeft != null && state.selectedRight != null) {
      final left = state.selectedLeft!;
      final right = state.selectedRight!;
      final correctPair = _originalPairs
          .where((p) => p.word == left)
          .firstOrNull;
      if (correctPair != null && correctPair.translation == right) {
        // Правильная пара!
        final newLeft = List<String>.from(state.leftColumn)..remove(left);
        final newRight = List<String>.from(state.rightColumn)..remove(right);
        // Бонус за скорость: чем больше времени осталось, тем выше награда
        final roundScore = 50 + state.timeLeft * 2;
        final newScore = state.playerScore + roundScore;
        final newPairs = state.pairsFound + 1;
        emit(
          state.copyWith(
            leftColumn: newLeft,
            rightColumn: newRight,
            playerScore: newScore,
            pairsFound: newPairs,
            selectedLeft: null,
            selectedRight: null,
          ),
        );
        if (newLeft.isEmpty) {
          _finishGame();
        }
      } else {
        // Ошибка – небольшой штраф
        emit(
          state.copyWith(
            selectedLeft: null,
            selectedRight: null,
            playerScore: state.playerScore - 10,
          ),
        );
      }
    }
  }

  Future<void> _finishGame() async {
    if (state.isFinished) return;
    _timer?.cancel();

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
    _timer?.cancel();
    return super.close();
  }
}
