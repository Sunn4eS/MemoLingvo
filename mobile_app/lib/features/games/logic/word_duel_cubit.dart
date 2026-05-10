import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';

class WordDuelState {
  final List<String> shuffledLetters;
  final List<String> playerAnswer;
  final String targetWord;
  final String promptWord; // русское слово
  final int playerScore;
  final int round;
  final int totalRounds;
  final bool isFinished;
  final int timeLeft;

  const WordDuelState({
    required this.shuffledLetters,
    required this.playerAnswer,
    required this.targetWord,
    required this.promptWord,
    required this.playerScore,
    required this.round,
    required this.totalRounds,
    required this.isFinished,
    required this.timeLeft,
  });

  factory WordDuelState.initial(int totalRounds) => WordDuelState(
    shuffledLetters: [],
    playerAnswer: [],
    targetWord: '',
    promptWord: '',
    playerScore: 0,
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
    int? round,
    int? totalRounds,
    bool? isFinished,
    int? timeLeft,
  }) {
    return WordDuelState(
      shuffledLetters: shuffledLetters ?? this.shuffledLetters,
      playerAnswer: playerAnswer ?? this.playerAnswer,
      targetWord: targetWord ?? this.targetWord,
      promptWord: promptWord ?? this.promptWord,
      playerScore: playerScore ?? this.playerScore,
      round: round ?? this.round,
      totalRounds: totalRounds ?? this.totalRounds,
      isFinished: isFinished ?? this.isFinished,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

class WordDuelCubit extends Cubit<WordDuelState> {
  final GameRepository _repository;
  final String email;
  Timer? _roundTimer;
  final List<db.Card> _cards;
  DateTime? _sessionStartTime;

  WordDuelCubit(this._repository, this.email, this._cards)
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
    if (letters.join() == card.word) letters.shuffle();
    emit(
      state.copyWith(
        shuffledLetters: letters,
        targetWord: card.word,
        promptWord: card.translation,
        playerAnswer: [],
        timeLeft: 15,
      ),
    );
    _startRoundTimer();
  }

  void _startRoundTimer() {
    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft <= 1) {
        _onTimeUp();
      } else {
        emit(state.copyWith(timeLeft: state.timeLeft - 1));
      }
    });
  }

  void addLetter(String letter) {
    if (state.shuffledLetters.contains(letter)) {
      final newShuffled = List<String>.from(state.shuffledLetters)
        ..remove(letter);
      final newAnswer = List<String>.from(state.playerAnswer)..add(letter);
      emit(
        state.copyWith(playerAnswer: newAnswer, shuffledLetters: newShuffled),
      );
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
    _roundTimer?.cancel();
    // Очки за раунд: базовая награда 50 + по 10 за каждую оставшуюся секунду
    final roundScore = 50 + state.timeLeft * 10;
    final newScore = state.playerScore + roundScore;
    emit(state.copyWith(playerScore: newScore, round: state.round + 1));
    _startRound();
  }

  void _onTimeUp() {
    _roundTimer?.cancel();
    // Время вышло — очков не даём, переходим к следующему раунду
    emit(state.copyWith(round: state.round + 1));
    _startRound();
  }

  Future<void> _finishGame() async {
    _roundTimer?.cancel();
    final totalTime = DateTime.now().difference(_sessionStartTime!).inSeconds;
    // Точность: все раунды решены правильно (грубая оценка)
    final accuracy = state.totalRounds > 0
        ? ((state.round / state.totalRounds) * 100).toInt()
        : 0;

    final serverUserId = await _repository.database.getServerUserId(email);
    if (serverUserId != null) {
      await _repository.saveGameResult(
        userId: serverUserId,
        gameType: 'word_duel',
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
    _roundTimer?.cancel();
    return super.close();
  }
}
