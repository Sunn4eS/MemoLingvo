import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/logic/word_duel_cubit.dart';
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/games/presentation/widgets/duel_board.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

class WordDuelScreen extends StatelessWidget {
  final String deckId;
  const WordDuelScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return const Center(child: Text('Ошибка авторизации'));

    return FutureBuilder<List<db.Card>>(
      future: _fetchCardsFromDeck(context, deckId),
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
        return BlocProvider(
          create: (_) => WordDuelCubit(
            context.read<GameRepository>(),
            email,
            cards,
          ),
          child: Scaffold(
            appBar: AppBar(title: const Text('Словесная дуэль')),
            body: BlocBuilder<WordDuelCubit, WordDuelState>(
              builder: (context, state) {
                if (state.isFinished) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context, true);
                  });
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events,
                            size: 80, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text('Игра окончена!',
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text('Ваш счёт: ${state.playerScore}'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
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

  Future<List<db.Card>> _fetchCardsFromDeck(BuildContext context, String deckId) async {
    final db = context.read<AppDatabase>();
    final query = db.select(db.cards)
  ..where((t) => t.deckId.equals(deckId))
  ..where((t) => t.isDeleted.equals(false));
    final cards = await query.get();
    if (cards.isEmpty) return [];
    cards.shuffle();
    return cards.take(7).toList();
  }
}