import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/games/domain/entities/user_rank.dart';
import 'package:memo_lingvo/features/games/logic/games_menu_cubit.dart';
import 'package:memo_lingvo/features/games/presentation/screens/word_duel_screen.dart';
import 'package:memo_lingvo/features/games/presentation/screens/sprint_pairs_screen.dart';
import 'package:memo_lingvo/features/games/presentation/widgets/leaderboard_widget.dart';
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return BlocProvider(
      create: (context) => GamesMenuCubit(context.read<GameRepository>())
        ..loadStats(userId),
      child: BlocBuilder<GamesMenuCubit, GamesMenuState>(
        builder: (context, state) {
          final rank = state.userRank;
          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (rank != null) _buildRankCard(rank),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _GameCard(
                        title: 'Словесная дуэль',
                        icon: Icons.abc,
                        color: Colors.deepPurple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>  WordDuelScreen(),
                          ),
                        ),
                      ),
                      _GameCard(
                        title: 'Спринт-пары',
                        icon: Icons.compare_arrows,
                        color: Colors.teal,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SprintPairsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Таблица лидеров'),
                  const LeaderboardWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankCard(UserRank rank) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.military_tech, color: Colors.amber.shade700, size: 32),
                const SizedBox(width: 8),
                Text(
                  rank.rankName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: rank.progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${rank.experience} / ${rank.experienceToNextRank} XP',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}