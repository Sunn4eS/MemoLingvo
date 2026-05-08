import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db;
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/games/logic/sprint_pairs_cubit.dart';
import 'package:memo_lingvo/features/games/presentation/widgets/pairs_board.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SprintPairsScreen extends StatelessWidget {
  const SprintPairsScreen({super.key});

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
            appBar: AppBar(title: const Text('Спринт-пары')),
            body: const Center(child: Text('Нет карточек для игры')),
          );
        }

        return BlocProvider(
          create: (_) => SprintPairsCubit(
            context.read<GameRepository>(),
            userId,
            {'averageSpeed': 3.5, 'accuracy': 75}, // профиль бота
            cards,
          ),
          child: const _SprintPairsBody(),
        );
      },
    );
  }
}

class _SprintPairsBody extends StatelessWidget {
  const _SprintPairsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Спринт-пары')),
      body: BlocBuilder<SprintPairsCubit, SprintPairsState>(
        builder: (context, state) {
          if (state.isFinished) {
            return _FinishResult(
              winner: state.winner,
              playerScore: state.playerScore,
              botScore: state.botScore,
              onBack: () => Navigator.pop(context),
            );
          }
          return PairsBoard(
            state: state,
            onSelectLeft: (id) => context.read<SprintPairsCubit>().selectLeft(id),
            onSelectRight: (id) => context.read<SprintPairsCubit>().selectRight(id),
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