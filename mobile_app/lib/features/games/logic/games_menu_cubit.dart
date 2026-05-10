import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/games/domain/entities/user_rank.dart';

class GamesMenuState {
  final UserRank? userRank;
  final int totalGamesPlayed;
  final int wins;

  const GamesMenuState({
    this.userRank,
    this.totalGamesPlayed = 0,
    this.wins = 0,
  });

  GamesMenuState copyWith({
    UserRank? userRank,
    int? totalGamesPlayed,
    int? wins,
  }) {
    return GamesMenuState(
      userRank: userRank ?? this.userRank,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      wins: wins ?? this.wins,
    );
  }
}

class GamesMenuCubit extends Cubit<GamesMenuState> {
  final GameRepository _repo;
  GamesMenuCubit(this._repo) : super(GamesMenuState());

  Future<void> loadStats(String email) async {  
    final userId = await _repo.database.getServerUserId(email);
    if (userId == null) {
      emit(GamesMenuState());
      return;
    }

    final rank = await _repo.getUserRank(userId);
    final sessions = await _repo.watchSessions(userId).first;
    final wins = sessions.where((s) => s.result == 'win').length;
    emit(
      GamesMenuState(
        userRank: rank,
        totalGamesPlayed: sessions.length,
        wins: wins,
      ),
    );
  }
}
