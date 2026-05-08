import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/games/logic/word_duel_cubit.dart';
import 'package:memo_lingvo/features/games/presentation/widgets/duel_board.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WordDuelScreen extends StatelessWidget {
  const WordDuelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final dbCards = context.read<db.AppDatabase>().select(context.read<db.AppDatabase>().cards).get();

    return FutureBuilder<List<db.Card>>(
      future: dbCards,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final cards = snapshot.data!;
        if (cards.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Словесная дуэль')),
            body: const Center(child: Text('Нет карточек для игры')),
          );
        }

        return BlocProvider(
          create: (_) => WordDuelCubit(
            context.read<GameRepository>(),
            userId,
            {'averageSpeed': 4.0, 'accuracy': 80}, // профиль бота
            cards,
          ),
          child: const _WordDuelBody(),
        );
      },
    );
  }
}

class _WordDuelBody extends StatelessWidget {
  const _WordDuelBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Словесная дуэль')),
      body: BlocBuilder<WordDuelCubit, WordDuelState>(
        builder: (context, state) {
          if (state.isFinished) {
            return _FinishResult(
              winner: state.winner,
              playerScore: state.playerScore,
              botScore: state.botScore,
              onBack: () => Navigator.pop(context),
            );
          }
          return DuelBoard(
            state: state,
            onLetterTap: (letter) => context.read<WordDuelCubit>().addLetter(letter),
            onRemoveLetter: (index) => context.read<WordDuelCubit>().removeLetter(index),
          );
        },
      ),
    );
  }
}

class _FinishResult extends StatelessWidget {
  final String? winner;
  final int playerScore;
  final int botScore;
  final VoidCallback onBack;
  const _FinishResult({
    required this.winner,
    required this.playerScore,
    required this.botScore,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isWinner = winner == 'player';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 80,
            color: isWinner ? Colors.amber : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            isWinner ? 'Победа!' : (winner == 'bot' ? 'Поражение' : 'Ничья'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Вы: $playerScore   Бот: $botScore'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('В меню'),
          ),
        ],
      ),
    );
  }
}