import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/profile/logic/profile_cubit.dart';
import 'package:memo_lingvo/features/profile/logic/profile_state.dart';
import 'package:memo_lingvo/features/profile/presentation/widgets/avatar_widget.dart';
import 'package:memo_lingvo/features/profile/presentation/screens/learned_words_screen.dart';

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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LearnedWordsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.school),
                    label: const Text('Словарь выученных слов'),
                  ),
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