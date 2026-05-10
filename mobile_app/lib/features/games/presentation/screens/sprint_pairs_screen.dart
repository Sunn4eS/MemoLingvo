import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/logic/sprint_pairs_cubit.dart';
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/games/presentation/widgets/pairs_board.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

class SprintPairsScreen extends StatelessWidget {
  const SprintPairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return const Center(child: Text('Ошибка авторизации'));

    return FutureBuilder<List<db.Card>>(
      future: _fetchCards(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        final cards = snapshot.data!;
        if (cards.length < 4) {
          return Scaffold(
            appBar: AppBar(title: const Text('Спринт-пары')),
            body: const Center(child: Text('Недостаточно карточек')),
          );
        }

        return _SprintProvider(email: email, cards: cards);
      },
    );
  }

  Future<List<db.Card>> _fetchCards(BuildContext context) async {
    final db = context.read<AppDatabase>();
    final query = db.select(db.cards)..where((t) => t.isDeleted.equals(false));
    final allCards = await query.get();
    allCards.shuffle();
    return allCards.take(8).toList(); // 8 пар для игры
  }
}

class _SprintProvider extends StatelessWidget {
  final String email;
  final List<db.Card> cards;
  const _SprintProvider({required this.email, required this.cards});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<GameRepository>();
    return FutureBuilder<Map<String, dynamic>>(
      future: repo.getBotProfile(email),
      builder: (context, snapshot) {
        final botProfile =
            snapshot.data ?? {'averageSpeed': 4.0, 'accuracy': 80};
        return BlocProvider(
          create: (_) => SprintPairsCubit(repo, email, botProfile, cards),
          child: Scaffold(
            appBar: AppBar(title: const Text('Спринт-пары')),
            body: BlocBuilder<SprintPairsCubit, SprintPairsState>(
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
                              ? 'Бот выиграл'
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
                return PairsBoard(state: state);
              },
            ),
          ),
        );
      },
    );
  }
}
