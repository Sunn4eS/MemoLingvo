import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/localization/locale_cubit.dart';
import 'package:memo_lingvo/core/network/api_client.dart';
import 'package:memo_lingvo/core/theme/theme_cubit.dart';
import 'package:memo_lingvo/features/auth/data/repositories/auth_repository.dart';
import 'package:memo_lingvo/features/auth/logic/auth_cubit.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';
import 'package:memo_lingvo/features/decks/data/repositories/deck_repository.dart';
import 'package:memo_lingvo/features/decks/logic/deck_cubit.dart';
import 'package:memo_lingvo/features/games/data/repositories/game_repository.dart';
import 'package:memo_lingvo/features/profile/data/repositories/profile_repository.dart';
import 'package:memo_lingvo/features/profile/logic/profile_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memo_lingvo/core/network/network_cubit.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  final AppDatabase database;
  final SharedPreferences prefs;

  const AppProviders({
    super.key,
    required this.child,
    required this.database,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: database),
        RepositoryProvider.value(value: prefs),
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => DeckRepository(database)),
        RepositoryProvider(create: (_) => CardRepository(database)),
        RepositoryProvider(
          create: (context) => ProfileRepository(
            context.read<AppDatabase>(),
            context.read<SharedPreferences>(),
          ),
        ),

        RepositoryProvider(
          create: (context) => GameRepository(
            context.read<AppDatabase>(),
            context.read<ApiClient>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(context.read<AuthRepository>(), database),
          ),
          BlocProvider(
            create: (context) => DeckCubit(context.read<DeckRepository>()),
          ),
          BlocProvider(create: (context) => NetworkCubit()),
          BlocProvider(create: (context) => ThemeCubit(prefs)),
          BlocProvider(create: (context) => LocaleCubit(prefs)),
          BlocProvider(
            create: (context) => ProfileCubit(
              context.read<ProfileRepository>(),
              FirebaseAuth.instance,
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
