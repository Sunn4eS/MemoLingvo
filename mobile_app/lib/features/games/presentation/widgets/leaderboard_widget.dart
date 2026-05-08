import 'package:flutter/material.dart';
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/games/domain/entities/user_rank.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameRepo = context.read<GameRepository>();
    return FutureBuilder<List<UserRank>>(
      future: gameRepo.getLeaderboard(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final leaders = snapshot.data!;
        if (leaders.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Нет данных для таблицы лидеров'),
            ),
          );
        }
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (int i = 0; i < leaders.length; i++)
                  _LeaderTile(
                    rank: i + 1,
                    userName: leaders[i].email,
                    experience: leaders[i].experience,
                    rankName: leaders[i].rankName,
                    isCurrentUser: false, // можно добавить логику сравнения
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeaderTile extends StatelessWidget {
  final int rank;
  final String userName;
  final int experience;
  final String rankName;
  final bool isCurrentUser;

  const _LeaderTile({
    required this.rank,
    required this.userName,
    required this.experience,
    required this.rankName,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.amber.shade50 : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: rank <= 3 ? Colors.amber.shade700 : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.split('@').first,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(rankName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            '$experience XP',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}