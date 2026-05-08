import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/profile/logic/profile_cubit.dart';
import 'package:memo_lingvo/features/profile/logic/profile_state.dart';
import 'package:memo_lingvo/features/profile/presentation/widgets/avatar_widget.dart';
import 'package:memo_lingvo/features/profile/presentation/screens/learned_words_screen.dart';
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/games/presentation/widgets/leaderboard_widget.dart';
import 'package:memo_lingvo/features/games/domain/entities/user_rank.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мой профиль')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }
          if (state is ProfileLoaded) {
            final profile = state.profile;
            final stats = state.stats;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AvatarWidget(avatarPath: state.avatarPath, size: 100),
                  const SizedBox(height: 16),
                  Text(profile.email, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 32),
                  _buildStatCard('Всего карточек', stats['total'] ?? 0),
                  _buildStatCard('Выучено', stats['mastered'] ?? 0),
                  _buildStatCard('В процессе', stats['learning'] ?? 0),
                  _buildStatCard('Новых', stats['new'] ?? 0),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LearnedWordsScreen()),
                    ),
                    icon: const Icon(Icons.school),
                    label: const Text('Словарь выученных слов'),
                  ),
                  const Divider(height: 32),
                  // Игровой блок
                  _GameStatsBlock(userId: profile.id),
                  const SizedBox(height: 16),
                  const LeaderboardWidget(),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        trailing: Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _GameStatsBlock extends StatelessWidget {
  final String userId;
  const _GameStatsBlock({required this.userId});

  @override
  Widget build(BuildContext context) {
    final gameRepo = context.read<GameRepository>();
    return FutureBuilder<UserRank>(
      future: gameRepo.getUserRank(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final rank = snapshot.data!;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Игровой ранг', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(rank.rankName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${rank.experience} XP', style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: rank.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}