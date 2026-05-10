import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';

/// Пара слов (оригинал и перевод) для игры
class Pair {
  final String word;
  final String translation;
  const Pair(this.word, this.translation);
}

class SprintPairsState {
  final List<String> leftColumn; // слова на иностранном языке
  final List<String> rightColumn; // переводы (перемешаны)
  final String? selectedLeft;
  final String? selectedRight;
  final int playerScore;
  final int botScore;
  final int playerPairsFound;
  final int botPairsFound;
  final int totalPairs;
  final double playerProgress; // доля найденных пар игроком
  final double botProgress; // доля найденных пар ботом
  final bool isFinished;
  final String? winner;
  final int timeLeft;

  const SprintPairsState({
    required this.leftColumn,
    required this.rightColumn,
    this.selectedLeft,
    this.selectedRight,
    required this.playerScore,
    required this.botScore,
    required this.playerPairsFound,
    required this.botPairsFound,
    required this.totalPairs,
    required this.playerProgress,
    required this.botProgress,
    required this.isFinished,
    this.winner,
    required this.timeLeft,
  });

  factory SprintPairsState.initial(List<Pair> pairs, int timePerGame) {
    final words = pairs.map((p) => p.word).toList();
    final translations = pairs.map((p) => p.translation).toList()..shuffle();
    return SprintPairsState(
      leftColumn: words,
      rightColumn: translations,
      playerScore: 0,
      botScore: 0,
      playerPairsFound: 0,
      botPairsFound: 0,
      totalPairs: pairs.length,
      playerProgress: 0.0,
      botProgress: 0.0,
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
    int? botScore,
    int? playerPairsFound,
    int? botPairsFound,
    int? totalPairs,
    double? playerProgress,
    double? botProgress,
    bool? isFinished,
    String? winner,
    int? timeLeft,
  }) {
    return SprintPairsState(
      leftColumn: leftColumn ?? this.leftColumn,
      rightColumn: rightColumn ?? this.rightColumn,
      selectedLeft: selectedLeft ?? this.selectedLeft,
      selectedRight: selectedRight ?? this.selectedRight,
      playerScore: playerScore ?? this.playerScore,
      botScore: botScore ?? this.botScore,
      playerPairsFound: playerPairsFound ?? this.playerPairsFound,
      botPairsFound: botPairsFound ?? this.botPairsFound,
      totalPairs: totalPairs ?? this.totalPairs,
      playerProgress: playerProgress ?? this.playerProgress,
      botProgress: botProgress ?? this.botProgress,
      isFinished: isFinished ?? this.isFinished,
      winner: winner ?? this.winner,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

class SprintPairsCubit extends Cubit<SprintPairsState> {
  final GameRepository _repository;
  final String email;
  final List<Pair> _originalPairs;
  Timer? _timer;
  Timer? _botTimer;
  final Random _random = Random();
  final Map<String, dynamic> _botProfile;
  DateTime? _sessionStartTime;

  SprintPairsCubit(
    this._repository,
    this.email,
    this._botProfile,
    List<db.Card> cards,
  ) : _originalPairs = cards.map((c) => Pair(c.word, c.translation)).toList(),
      super(
        SprintPairsState.initial(
          cards.map((c) => Pair(c.word, c.translation)).toList(),
          60, // 60 секунд на игру
        ),
      ) {
    _sessionStartTime = DateTime.now();
    _startTimers();
  }

  void _startTimers() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft <= 1) {
        _timer?.cancel();
        _finishGame();
      } else {
        emit(state.copyWith(timeLeft: state.timeLeft - 1));
      }
    });

    // Бот пытается найти пару с интервалом, зависящим от его скорости
    _scheduleBotMove();
  }

  void _scheduleBotMove() {
    _botTimer?.cancel();
    final delay = Duration(
      milliseconds:
          (1000 + _random.nextInt(3000) * (_botProfile['averageSpeed'] / 5.0))
              .toInt(),
    );
    _botTimer = Timer(delay, () {
      if (state.isFinished) return;
      _botFindPair();
    });
  }

  void _botFindPair() {
    // Упрощённо: бот просто удаляет одну пару из оставшихся
    if (state.leftColumn.isEmpty) {
      _finishGame();
      return;
    }
    final index = _random.nextInt(state.leftColumn.length);
    final word = state.leftColumn[index];
    final correctTranslation = _originalPairs
        .firstWhere((p) => p.word == word)
        .translation;
    // Проверяем, есть ли перевод в правой колонке
    if (state.rightColumn.contains(correctTranslation)) {
      final newLeft = List<String>.from(state.leftColumn)..remove(word);
      final newRight = List<String>.from(state.rightColumn)
        ..remove(correctTranslation);
      final newBotScore = state.botScore + 100;
      final newBotPairs = state.botPairsFound + 1;
      emit(
        state.copyWith(
          leftColumn: newLeft,
          rightColumn: newRight,
          botScore: newBotScore,
          botPairsFound: newBotPairs,
          botProgress: newBotPairs / state.totalPairs,
          selectedLeft: null,
          selectedRight: null,
        ),
      );
      if (newLeft.isEmpty) {
        _finishGame();
      } else {
        _scheduleBotMove();
      }
    } else {
      // Если перевод уже убран (маловероятно), пропускаем
      _scheduleBotMove();
    }
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
        final newScore = state.playerScore + 100;
        final newPairs = state.playerPairsFound + 1;
        emit(
          state.copyWith(
            leftColumn: newLeft,
            rightColumn: newRight,
            playerScore: newScore,
            playerPairsFound: newPairs,
            playerProgress: newPairs / state.totalPairs,
            selectedLeft: null,
            selectedRight: null,
          ),
        );
        if (newLeft.isEmpty) {
          _finishGame();
        }
      } else {
        // Ошибка – снимаем выделение и небольшой штраф (не блокируем)
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
    _botTimer?.cancel();

    String winner = 'draw';
    if (state.playerScore > state.botScore) {
      winner = 'player';
    } else if (state.botScore > state.playerScore) {
      winner = 'bot';
    }

    final totalTime = DateTime.now().difference(_sessionStartTime!).inSeconds;
    final accuracy = (state.playerPairsFound > 0)
        ? ((state.playerPairsFound / (state.playerPairsFound + 1)) * 100)
              .toInt()
        : 0; // Упрощённо

    final serverUserId = await _repository.database.getServerUserId(email);
    if (serverUserId != null) {
      await _repository.saveGameResult(
        userId: serverUserId,
        gameType: 'sprint_pairs',
        result: winner == 'player'
            ? 'win'
            : (winner == 'bot' ? 'lose' : 'draw'),
        score: state.playerScore,
        timeTakenSeconds: totalTime,
        accuracyPercent: accuracy,
      );
    }

    emit(state.copyWith(isFinished: true, winner: winner));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _botTimer?.cancel();
    return super.close();
  }
}
