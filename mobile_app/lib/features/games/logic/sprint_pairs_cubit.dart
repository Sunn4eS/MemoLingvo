import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';

class SprintPairsState {
  final List<PairItem> leftItems;    // иностранные слова
  final List<PairItem> rightItems;   // переводы
  final String? selectedLeftId;
  final String? selectedRightId;
  final int playerScore;
  final int botScore;
  final int pairedCount;            // сколько пар разгадано
  final int totalPairs;             // изначальное количество пар
  final int mistakes;               // ошибки игрока
  final bool isFinished;
  final String? winner;
  final int timeLeft;               // общий таймер (опционально)

  const SprintPairsState({
    required this.leftItems,
    required this.rightItems,
    this.selectedLeftId,
    this.selectedRightId,
    required this.playerScore,
    required this.botScore,
    required this.pairedCount,
    required this.totalPairs,
    required this.mistakes,
    required this.isFinished,
    this.winner,
    required this.timeLeft,
  });

  SprintPairsState copyWith({
    List<PairItem>? leftItems,
    List<PairItem>? rightItems,
    String? selectedLeftId,
    String? selectedRightId,
    int? playerScore,
    int? botScore,
    int? pairedCount,
    int? totalPairs,
    int? mistakes,
    bool? isFinished,
    String? winner,
    int? timeLeft,
  }) {
    return SprintPairsState(
      leftItems: leftItems ?? this.leftItems,
      rightItems: rightItems ?? this.rightItems,
      selectedLeftId: selectedLeftId,
      selectedRightId: selectedRightId,
      playerScore: playerScore ?? this.playerScore,
      botScore: botScore ?? this.botScore,
      pairedCount: pairedCount ?? this.pairedCount,
      totalPairs: totalPairs ?? this.totalPairs,
      mistakes: mistakes ?? this.mistakes,
      isFinished: isFinished ?? this.isFinished,
      winner: winner,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }

  factory SprintPairsState.initial(List<db.Card> cards) {
    final itemCount = min(cards.length, 10);
    final selectedCards = cards.sublist(0, itemCount);
    final left = <PairItem>[];
    final right = <PairItem>[];
    for (final card in selectedCards) {
      final id = card.id; // используем id как связку
      left.add(PairItem(id: id, text: card.word));
      right.add(PairItem(id: id, text: card.translation));
    }
    left.shuffle();
    right.shuffle();
    return SprintPairsState(
      leftItems: left,
      rightItems: right,
      playerScore: 0,
      botScore: 0,
      pairedCount: 0,
      totalPairs: itemCount,
      mistakes: 0,
      isFinished: false,
      timeLeft: 90, // общий таймер
    );
  }
}

/// Элемент пары: связь через id
class PairItem {
  final String id;       // общий идентификатор пары (card.id)
  final String text;
  final bool matched;

  const PairItem({required this.id, required this.text, this.matched = false});

  PairItem copyWith({String? id, String? text, bool? matched}) {
    return PairItem(
      id: id ?? this.id,
      text: text ?? this.text,
      matched: matched ?? this.matched,
    );
  }
}

class SprintPairsCubit extends Cubit<SprintPairsState> {
  final GameRepository _repository;
  final String userId;
  final Map<String, dynamic> _botProfile;
  Timer? _gameTimer;
  Timer? _botTimer;
  int _botNextAction = 0; // индекс следующей пары, которую бот попытается соединить

  SprintPairsCubit(
    this._repository,
    this.userId,
    this._botProfile,
    List<db.Card> cards,
  ) : super(SprintPairsState.initial(cards)) {
    if (cards.isNotEmpty) {
      _startTimers();
    } else {
      emit(state.copyWith(isFinished: true, winner: 'draw'));
    }
  }

  void _startTimers() {
    // Общий таймер игры
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft <= 1) {
        _finishGame();
      } else {
        emit(state.copyWith(timeLeft: state.timeLeft - 1));
      }
    });

    // Планируем действия бота
    _scheduleBotMove();
  }

  void _scheduleBotMove() {
    _botTimer?.cancel();
    if (state.isFinished || _botNextAction >= state.totalPairs) return;

    final botDelay = (_botProfile['averageSpeed'] as num?)?.toDouble() ?? 4.0;
    final variation = Random().nextDouble() * 3.0 - 1.5;
    final delay = max(1.0, botDelay + variation);
    _botTimer = Timer(Duration(milliseconds: (delay * 1000).toInt()), _botMakePair);
  }

  void _botMakePair() {
    if (state.isFinished) return;

    // Бот находит первую несовпавшую пару
    final leftIndex = state.leftItems.indexWhere((item) => !item.matched);
    if (leftIndex == -1) return;

    final targetId = state.leftItems[leftIndex].id;
    final rightIndex = state.rightItems.indexWhere((item) => item.id == targetId && !item.matched);
    if (rightIndex == -1) return;

    // Помечаем как совпавшую
    final newLeft = state.leftItems.map((item) => item.id == targetId ? item.copyWith(matched: true) : item).toList();
    final newRight = state.rightItems.map((item) => item.id == targetId ? item.copyWith(matched: true) : item).toList();
    final newPaired = state.pairedCount + 1;
    final newBotScore = state.botScore + 50;

    emit(state.copyWith(
      leftItems: newLeft,
      rightItems: newRight,
      pairedCount: newPaired,
      botScore: newBotScore,
    ));

    _botNextAction++;
    if (newPaired >= state.totalPairs) {
      _finishGame();
    } else {
      _scheduleBotMove();
    }
  }

  void selectLeft(String itemId) {
    if (state.isFinished || state.leftItems.any((i) => i.id == itemId && i.matched)) return;
    if (state.selectedLeftId == itemId) {
      emit(state.copyWith(selectedLeftId: null));
    } else {
      emit(state.copyWith(selectedLeftId: itemId));
    }
    _checkMatch();
  }

  void selectRight(String itemId) {
    if (state.isFinished || state.rightItems.any((i) => i.id == itemId && i.matched)) return;
    if (state.selectedRightId == itemId) {
      emit(state.copyWith(selectedRightId: null));
    } else {
      emit(state.copyWith(selectedRightId: itemId));
    }
    _checkMatch();
  }

  void _checkMatch() {
    if (state.selectedLeftId == null || state.selectedRightId == null) return;

    final leftId = state.selectedLeftId!;
    final rightId = state.selectedRightId!;

    if (leftId == rightId) {
      // Успешная пара
      final newLeft = state.leftItems.map((item) => item.id == leftId ? item.copyWith(matched: true) : item).toList();
      final newRight = state.rightItems.map((item) => item.id == rightId ? item.copyWith(matched: true) : item).toList();
      final newPaired = state.pairedCount + 1;
      final newScore = state.playerScore + 50;
      emit(state.copyWith(
        leftItems: newLeft,
        rightItems: newRight,
        pairedCount: newPaired,
        playerScore: newScore,
        selectedLeftId: null,
        selectedRightId: null,
      ));
      if (newPaired >= state.totalPairs) {
        _finishGame();
      }
    } else {
      // Ошибка: штраф и сброс выделения
      emit(state.copyWith(
        mistakes: state.mistakes + 1,
        selectedLeftId: null,
        selectedRightId: null,
      ));
    }
  }

  Future<void> _finishGame() async {
    _gameTimer?.cancel();
    _botTimer?.cancel();

    String winner = 'draw';
    if (state.playerScore > state.botScore) {
      winner = 'player';
    } else if (state.botScore > state.playerScore) {
      winner = 'bot';
    }

    final totalAttempts = state.pairedCount + state.mistakes;
    final accuracy = totalAttempts > 0 ? ((state.pairedCount / totalAttempts) * 100).round() : 100;

    await _repository.saveGameResult(
      userId: userId,
      gameType: 'sprint_pairs',
      result: winner == 'player' ? 'win' : (winner == 'bot' ? 'lose' : 'draw'),
      score: state.playerScore,
      timeTakenSeconds: 90 - state.timeLeft,
      accuracyPercent: accuracy,
    );

    emit(state.copyWith(isFinished: true, winner: winner));
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _botTimer?.cancel();
    return super.close();
  }
}