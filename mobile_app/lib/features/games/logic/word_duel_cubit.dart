import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';

class WordDuelState {
  final List<String> shuffledLetters;
  final List<String> playerAnswer;
  final String targetWord;
  final String promptWord;         // русское слово
  final int playerScore;
  final int botScore;
  final double playerProgress;     // 0..1
  final double botProgress;
  final int round;
  final int totalRounds;
  final bool isFinished;
  final String? winner;            // 'player', 'bot', 'draw'
  final int timeLeft;

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

  factory WordDuelState.initial(int totalRounds) => WordDuelState(
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
      winner: winner ?? this.winner,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

class WordDuelCubit extends Cubit<WordDuelState> {
  final GameRepository _repository;
  final String email;
  Timer? _timer;
  Timer? _botTimer;
  final Map<String, dynamic> _botProfile;
  final List<db.Card> _cards;
  final Random _random = Random();
  DateTime? _sessionStartTime;

  WordDuelCubit(this._repository, this.email, this._botProfile, this._cards)
      : super(WordDuelState.initial(_cards.length > 5 ? 5 : _cards.length)) {
    _sessionStartTime = DateTime.now();
    _startRound();
  }

  void _startRound() {
    if (state.round >= state.totalRounds) {
      _finishGame();
      return;
    }
    final card = _cards[state.round % _cards.length];
    final letters = card.word.split('')..shuffle();
    // Проверяем, чтобы буквы точно перемешались не в исходном порядке
    if (letters.join() == card.word) letters.shuffle();
    emit(state.copyWith(
      shuffledLetters: letters,
      targetWord: card.word,
      promptWord: card.translation,
      playerAnswer: [],
      timeLeft: 15,
    ));
    _startTimers();
  }

  void _startTimers() {
    _timer?.cancel();
    _botTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft <= 1) {
        _onTimeUp();
      } else {
        emit(state.copyWith(timeLeft: state.timeLeft - 1));
      }
    });

    // Бот “думает” случайное время в зависимости от его средней скорости
    final botDelay = Duration(
      milliseconds: (500 + _random.nextInt(3000) * (_botProfile['averageSpeed'] / 5.0)).toInt(),
    );
    _botTimer = Timer(botDelay, () {
      if (!state.isFinished && state.playerAnswer.join() != state.targetWord) {
        _botSolve();
      }
    });
  }

  void addLetter(String letter) {
    if (state.shuffledLetters.contains(letter)) {
      final newShuffled = List<String>.from(state.shuffledLetters)..remove(letter);
      final newAnswer = List<String>.from(state.playerAnswer)..add(letter);
      emit(state.copyWith(playerAnswer: newAnswer, shuffledLetters: newShuffled));
      if (newAnswer.join() == state.targetWord) {
        _playerSolved();
      }
    }
  }

  void removeLetter(int index) {
    final letter = state.playerAnswer[index];
    final newAnswer = List<String>.from(state.playerAnswer)..removeAt(index);
    final newShuffled = List<String>.from(state.shuffledLetters)..add(letter);
    emit(state.copyWith(playerAnswer: newAnswer, shuffledLetters: newShuffled));
  }

  void _playerSolved() {
    _timer?.cancel();
    _botTimer?.cancel();
    final newScore = state.playerScore + 100;
    final progress = (state.round + 1) / state.totalRounds;
    emit(state.copyWith(
      playerScore: newScore,
      playerProgress: progress,
      round: state.round + 1,
    ));
    _startRound();
  }

  void _botSolve() {
    if (state.isFinished) return;
    _timer?.cancel();
    final newScore = state.botScore + 100;
    final progress = (state.round + 1) / state.totalRounds;
    emit(state.copyWith(
      botScore: newScore,
      botProgress: progress,
      round: state.round + 1,
    ));
    _startRound();
  }

  void _onTimeUp() {
    _timer?.cancel();
    _botTimer?.cancel();
    // Бот получает очки за раунд
    final newBotScore = state.botScore + 50;
    emit(state.copyWith(
      botScore: newBotScore,
      botProgress: (state.round + 1) / state.totalRounds,
      round: state.round + 1,
    ));
    _startRound();
  }

  Future<void> _finishGame() async {
    _timer?.cancel();
    _botTimer?.cancel();
    String winner = 'draw';
    if (state.playerScore > state.botScore) {
      winner = 'player';
    } else if (state.botScore > state.playerScore) {
      winner = 'bot';
    }

    final totalTime = DateTime.now().difference(_sessionStartTime!).inSeconds;
    final accuracy = state.playerScore > 0 ? 100 : 0; // Упрощённо

    final serverUserId = await _repository.database.getServerUserId(email);
    if (serverUserId != null) {
      await _repository.saveGameResult(
        userId: serverUserId,
        gameType: 'word_duel',
        result: winner == 'player' ? 'win' : (winner == 'bot' ? 'lose' : 'draw'),
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