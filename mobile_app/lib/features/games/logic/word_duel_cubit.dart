import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';

class WordDuelState {
  final List<String> shuffledLetters;   // все доступные буквы
  final List<String> playerAnswer;      // выбранные буквы
  final String targetWord;              // правильное слово (англ.)
  final String promptWord;              // подсказка (русский перевод)
  final int playerScore;
  final int botScore;
  final double playerProgress;          // от 0 до 1
  final double botProgress;
  final int round;                      // текущий раунд (0-based)
  final int totalRounds;
  final bool isFinished;
  final String? winner;                 // 'player', 'bot', 'draw'
  final int timeLeft;                   // секунд до конца раунда

  const WordDuelState({
    required this.shuffledLetters,
    required this.playerAnswer,
    required this.targetWord,
    required this.promptWord,
    required this.playerScore,
    required this.botScore,
    required this.playerProgress,
    required this.botProgress,
    required this.round,
    required this.totalRounds,
    required this.isFinished,
    this.winner,
    required this.timeLeft,
  });

  WordDuelState copyWith({
    List<String>? shuffledLetters,
    List<String>? playerAnswer,
    String? targetWord,
    String? promptWord,
    int? playerScore,
    int? botScore,
    double? playerProgress,
    double? botProgress,
    int? round,
    int? totalRounds,
    bool? isFinished,
    String? winner,
    int? timeLeft,
  }) {
    return WordDuelState(
      shuffledLetters: shuffledLetters ?? this.shuffledLetters,
      playerAnswer: playerAnswer ?? this.playerAnswer,
      targetWord: targetWord ?? this.targetWord,
      promptWord: promptWord ?? this.promptWord,
      playerScore: playerScore ?? this.playerScore,
      botScore: botScore ?? this.botScore,
      playerProgress: playerProgress ?? this.playerProgress,
      botProgress: botProgress ?? this.botProgress,
      round: round ?? this.round,
      totalRounds: totalRounds ?? this.totalRounds,
      isFinished: isFinished ?? this.isFinished,
      winner: winner,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }

  // Начальное состояние до первого раунда
  factory WordDuelState.initial({int totalRounds = 5}) {
    return WordDuelState(
      shuffledLetters: [],
      playerAnswer: [],
      targetWord: '',
      promptWord: '',
      playerScore: 0,
      botScore: 0,
      playerProgress: 0.0,
      botProgress: 0.0,
      round: 0,
      totalRounds: totalRounds,
      isFinished: false,
      timeLeft: 15,
    );
  }
}

class WordDuelCubit extends Cubit<WordDuelState> {
  final GameRepository _repository;
  final String userId;
  final List<db.Card> _cards;
  final Map<String, dynamic> _botProfile; // содержит 'averageSpeed' и 'accuracy'
  Timer? _roundTimer;
  Timer? _botTimer;

  WordDuelCubit(
    this._repository,
    this.userId,
    this._botProfile,
    this._cards,
  ) : super(WordDuelState.initial(totalRounds: _cards.isEmpty ? 1 : _cards.length.clamp(3, 10))) {
    // Инициализация первого раунда
    if (_cards.isNotEmpty) {
      _startRound();
    } else {
      emit(state.copyWith(isFinished: true, winner: 'draw'));
    }
  }

  void _startRound() {
    if (state.round >= state.totalRounds) {
      _finishGame();
      return;
    }
    final card = _cards[state.round % _cards.length];
    final letters = card.word.toLowerCase().split('');
    letters.shuffle(Random());
    // Гарантируем, что все буквы присутствуют
    emit(state.copyWith(
      shuffledLetters: letters,
      targetWord: card.word.toLowerCase(),
      promptWord: card.translation.isNotEmpty ? card.translation : card.word,
      playerAnswer: [],
      timeLeft: 15,
      isFinished: false,
      winner: null,
    ));
    _startTimers();
  }

  void _startTimers() {
    _roundTimer?.cancel();
    _botTimer?.cancel();

    // Таймер обратного отсчёта
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft <= 1) {
        _onTimeUp();
      } else {
        emit(state.copyWith(timeLeft: state.timeLeft - 1));
      }
    });

    // Бот пытается решить спустя время, зависящее от averageSpeed
    final botDelay = (_botProfile['averageSpeed'] as num?)?.toDouble() ?? 4.0;
    final variation = Random().nextDouble() * 3.0 - 1.5;
    final totalDelay = max(1.0, botDelay + variation);
    _botTimer = Timer(Duration(milliseconds: (totalDelay * 1000).toInt()), () {
      if (!state.isFinished) _botSolve();
    });
  }

  void addLetter(String letter) {
    if (state.isFinished) return;
    final shuffled = List<String>.from(state.shuffledLetters);
    final index = shuffled.indexOf(letter);
    if (index == -1) return;
    shuffled.removeAt(index);
    final answer = List<String>.from(state.playerAnswer)..add(letter);
    emit(state.copyWith(shuffledLetters: shuffled, playerAnswer: answer));

    if (answer.join('') == state.targetWord) {
      _playerSolved();
    }
  }

  void removeLetter(int index) {
    if (state.isFinished || index < 0 || index >= state.playerAnswer.length) return;
    final letter = state.playerAnswer[index];
    final newAnswer = List<String>.from(state.playerAnswer)..removeAt(index);
    final newShuffled = List<String>.from(state.shuffledLetters)..add(letter);
    emit(state.copyWith(playerAnswer: newAnswer, shuffledLetters: newShuffled));
  }

  void _playerSolved() {
    _roundTimer?.cancel();
    _botTimer?.cancel();
    final newScore = state.playerScore + 100;
    final newRound = state.round + 1;
    final progress = newRound / state.totalRounds;
    emit(state.copyWith(
      playerScore: newScore,
      playerProgress: progress,
      round: newRound,
    ));
    _startRound();
  }

  void _botSolve() {
    if (state.isFinished) return;
    _roundTimer?.cancel();
    _botTimer?.cancel();
    // С вероятностью, равной accuracy бота, он действительно решает
    final accuracy = (_botProfile['accuracy'] as num?)?.toDouble() ?? 80.0;
    final roll = Random().nextDouble() * 100;
    if (roll <= accuracy) {
      final newBotScore = state.botScore + 100;
      final progress = (state.round + 1) / state.totalRounds;
      emit(state.copyWith(
        botScore: newBotScore,
        botProgress: progress,
        round: state.round + 1,
      ));
      _startRound();
    } else {
      // Бот ошибся – время продолжает идти, он не получает очков
      // Можно дать ему вторую попытку позже
      final retryDelay = 2 + Random().nextInt(3);
      _botTimer = Timer(Duration(seconds: retryDelay), () {
        if (!state.isFinished) _botSolve();
      });
    }
  }

  void _onTimeUp() {
    if (state.isFinished) return;
    _roundTimer?.cancel();
    _botTimer?.cancel();
    // Время вышло – очко боту
    final newBotScore = state.botScore + 50;
    final newRound = state.round + 1;
    final progress = newRound / state.totalRounds;
    emit(state.copyWith(
      botScore: newBotScore,
      botProgress: progress,
      round: newRound,
    ));
    _startRound();
  }

  Future<void> _finishGame() async {
    _roundTimer?.cancel();
    _botTimer?.cancel();
    String winner = 'draw';
    if (state.playerScore > state.botScore) {
      winner = 'player';
    } else if (state.botScore > state.playerScore) {
      winner = 'bot';
    }

    // Сохраняем сессию
    await _repository.saveGameResult(
      userId: userId,
      gameType: 'word_duel',
      result: winner == 'player' ? 'win' : (winner == 'bot' ? 'lose' : 'draw'),
      score: state.playerScore,
      timeTakenSeconds: 0,   // можно рассчитать реальное время
      accuracyPercent: 100,  // упрощённо
    );

    emit(state.copyWith(isFinished: true, winner: winner));
  }

  @override
  Future<void> close() {
    _roundTimer?.cancel();
    _botTimer?.cancel();
    return super.close();
  }
}