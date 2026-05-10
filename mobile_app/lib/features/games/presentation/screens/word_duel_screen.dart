import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/logic/word_duel_cubit.dart';
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/games/presentation/widgets/duel_board.dart';

import 'package:memo_lingvo/core/database/app_database.dart';

class WordDuelScreen extends StatelessWidget {
  const WordDuelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return const Center(child: Text('Ошибка авторизации'));

    return FutureBuilder<List<db.Card>>(
      future: _fetchRandomCards(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        final cards = snapshot.data!;
        if (cards.length < 3) {
          return Scaffold(
            appBar: AppBar(title: const Text('Словесная дуэль')),
            body: const Center(child: Text('Недостаточно карточек для игры')),
          );
        }

        return _GameProviderWrapper(email: email, cards: cards);
      },
    );
  }

  Future<List<db.Card>> _fetchRandomCards(BuildContext context) async {
    final db = context.read<AppDatabase>();
    final query = db.select(db.cards)..where((t) => t.isDeleted.equals(false));
    final allCards = await query.get();
    if (allCards.isEmpty) return [];
    allCards.shuffle();
    return allCards.take(7).toList(); // немного карточек для раундов
  }
}

class _GameProviderWrapper extends StatelessWidget {
  final String email;
  final List<db.Card> cards;
  const _GameProviderWrapper({required this.email, required this.cards});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<GameRepository>();
    return FutureBuilder<Map<String, dynamic>>(
      future: repo.getBotProfile(email), // бот получает профиль текущего игрока
      builder: (context, snapshot) {
        final botProfile =
            snapshot.data ?? {'averageSpeed': 4.0, 'accuracy': 80};
        return BlocProvider(
          create: (_) => WordDuelCubit(repo, email, botProfile, cards),
          child: Scaffold(
            appBar: AppBar(title: const Text('Словесная дуэль')),
            body: BlocBuilder<WordDuelCubit, WordDuelState>(
              builder: (context, state) {
                if (state.isFinished) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          state.winner == 'player'
                              ? Icons.emoji_events
                              : Icons.sentiment_dissatisfied,
                          size: 80,
                          color: state.winner == 'player'
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.winner == 'player'
                              ? 'Победа!'
                              : state.winner == 'bot'
                              ? 'Победил бот'
                              : 'Ничья',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Ваш счёт: ${state.playerScore}'),
                        Text('Счёт бота: ${state.botScore}'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('В меню игр'),
                        ),
                      ],
                    ),
                  );
                }
                return DuelBoard(state: state);
              },
            ),
          ),
        );
      },
    );
  }
}
