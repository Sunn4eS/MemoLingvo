import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';

class WordDuelState {
  final List<String> shuffledLetters;
  final List<String> playerAnswer;
  final String targetWord;
  final String promptWord;
  final int playerScore;
  final int round;
  final int totalRounds;
  final bool isFinished;
  final int totalTimeLeft;

  const WordDuelState({
    required this.shuffledLetters,
    required this.playerAnswer,
    required this.targetWord,
    required this.promptWord,
    required this.playerScore,
    required this.round,
    required this.totalRounds,
    required this.isFinished,
    required this.totalTimeLeft,
  });

  factory WordDuelState.initial(int totalRounds, int totalTime) =>
      WordDuelState(
        shuffledLetters: [],
        playerAnswer: [],
        targetWord: '',
        promptWord: '',
        playerScore: 0,
        round: 0,
        totalRounds: totalRounds,
        isFinished: false,
        totalTimeLeft: totalTime,
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
    int? totalTimeLeft,
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
      totalTimeLeft: totalTimeLeft ?? this.totalTimeLeft,
    );
  }
}

class WordDuelCubit extends Cubit<WordDuelState> {
  final GameRepository _repository;
  final String email;
  Timer? _gameTimer;
  final List<db.Card> _cards;
  DateTime? _sessionStartTime;
  static const int totalGameTime = 90;

  WordDuelCubit(this._repository, this.email, this._cards)
    : super(
        WordDuelState.initial(
          _cards.length > 5 ? 5 : _cards.length,
          totalGameTime,
        ),
      ) {
    _sessionStartTime = DateTime.now();
    _startGameTimer();
    _startRound();
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

  void _startRound() {
    if (state.isFinished) return;
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
      ),
    );
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

  void skipRound() {
    if (state.isFinished) return;

    emit(state.copyWith(round: state.round + 1));
    _startRound();
  }

  void _playerSolved() {
    final roundScore = 50 + state.totalTimeLeft;
    emit(
      state.copyWith(
        playerScore: state.playerScore + roundScore,
        round: state.round + 1,
      ),
    );
    _startRound();
  }

  Future<void> _finishGame() async {
    if (state.isFinished) return;
    _gameTimer?.cancel();
    final totalTime = DateTime.now().difference(_sessionStartTime!).inSeconds;
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
    _gameTimer?.cancel();
    return super.close();
  }
}
