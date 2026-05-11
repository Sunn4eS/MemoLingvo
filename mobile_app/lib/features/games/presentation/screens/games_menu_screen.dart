import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_lingvo/features/games/domain/entities/user_rank.dart';
import 'package:memo_lingvo/features/games/logic/games_menu_cubit.dart';
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/games/presentation/screens/word_duel_screen.dart';
import 'package:memo_lingvo/features/games/presentation/screens/sprint_pairs_screen.dart';
import 'package:memo_lingvo/features/games/presentation/widgets/leaderboard_widget.dart';
import 'package:memo_lingvo/core/database/app_database.dart' show DeckWithCount;
import 'package:memo_lingvo/features/profile/logic/profile_cubit.dart';

enum GameType { wordDuel, sprintPairs }

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return const Center(child: Text('Вы не авторизованы'));

    return BlocProvider(
      create: (_) =>
          GamesMenuCubit(context.read<GameRepository>())..loadStats(email),
      child: BlocBuilder<GamesMenuCubit, GamesMenuState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Игры')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.userRank != null) _buildRankCard(state.userRank!),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _GameCard(
                        title: 'Словесная дуэль',
                        icon: Icons.abc,
                        color: Colors.deepPurple,
                        onTap: () => _startGame(context, GameType.wordDuel),
                      ),
                      _GameCard(
                        title: 'Спринт-пары',
                        icon: Icons.compare_arrows,
                        color: Colors.teal,
                        onTap: () =>
                            _startGame(context, GameType.sprintPairs),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const LeaderboardWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _startGame(BuildContext context, GameType type) async {
    final repo = context.read<GameRepository>();
    final email = FirebaseAuth.instance.currentUser!.email!;
    final serverUserId = await repo.database.getServerUserId(email);
    if (serverUserId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Профиль не найден')));
      }
      return;
    }
    // Получаем список колод пользователя
    final decks = await repo.getDecksForUser(serverUserId);
    if (decks.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('У вас нет колод')));
      }
      return;
    }
    // Диалог выбора колоды
    final selectedDeck = await showDialog<DeckWithCount>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Выберите колоду'),
        children: decks
            .map((d) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext, d),
                  child:
                      Text('${d.deck.title} (карточек: ${d.cardCount})'),
                ))
            .toList(),
      ),
    );
    if (selectedDeck == null) return;

    // Запускаем экран игры
    Widget gameScreen;
    if (type == GameType.wordDuel) {
      gameScreen = WordDuelScreen(deckId: selectedDeck.deck.id);
    } else {
      gameScreen = SprintPairsScreen(deckId: selectedDeck.deck.id);
    }
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => gameScreen),
    );
    // После возврата (result может быть true, если игра завершена)
    if (result == true && context.mounted) {
      // Обновляем статистику меню
      context.read<GamesMenuCubit>().loadStats(email);
      // Обновляем профиль (рейтинг)
      context.read<ProfileCubit>().loadProfile();
    }
  }

  Widget _buildRankCard(UserRank rank) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(rank.rankName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: rank.progress),
            const SizedBox(height: 4),
            Text('${rank.experience} / ${rank.experienceToNextRank} XP'),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _GameCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}