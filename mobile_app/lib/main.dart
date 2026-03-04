import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lingo_cards/core/localization/l10n/app_localizations.dart';
import 'package:lingo_cards/features/auth/logic/auth_cubit.dart';
import 'package:lingo_cards/features/auth/presentation/screens/register_screen.dart';
import 'package:lingo_cards/features/auth/presentation/screens/splash_screen.dart';
import 'package:lingo_cards/features/auth/presentation/screens/welcome_screen.dart';
import 'package:lingo_cards/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingo_cards/features/auth/data/repositories/auth_repository.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoLingvo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ru')],
      localeResolutionCallback: (locale, supportedLocales) {
        return const Locale('ru');
      },
      routes: {
        '/register': (context) => RegisterScreen(),
        '/welcome': (context) => WelcomeScreen(),
      },
      home: SplashScreen(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiBlocProvider(
      providers: [
        // RepositoryProvider для AuthRepository (неблоковый провайдер)
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        // BlocProvider для AuthCubit, который зависит от репозитория
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(context.read<AuthRepository>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}
