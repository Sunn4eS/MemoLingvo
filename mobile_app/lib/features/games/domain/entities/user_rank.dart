class UserRank {
  final String userId;
  final String email;
  final int experience;
  final int rank;

  const UserRank({
    required this.userId,
    required this.email,
    required this.experience,
    required this.rank,
  });

  String get rankName {
    switch (rank) {
      case 0:
        return 'Новичок';
      case 1:
        return 'Любитель';
      case 2:
        return 'Знаток';
      case 3:
        return 'Мастер';
      default:
        return 'Легенда';
    }
  }

  int get experienceToNextRank => (rank + 1) * 4000;
  double get progress => experience / experienceToNextRank;
}
