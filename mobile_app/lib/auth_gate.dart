import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';

import 'package:memo_lingvo/core/localization/locale_cubit.dart';
import 'package:memo_lingvo/core/theme/theme_cubit.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/login_sreen.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/register_screen.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/welcome_screen.dart';
import 'package:memo_lingvo/features/home/presentation/screens/main_wrapper.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/splash_screen.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Stream<firebase_auth.User?> _authStateChanges;

  @override
  void initState() {
    super.initState();
    _authStateChanges = firebase_auth.FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final themeMode = context.watch<ThemeCubit>().state;

    return MaterialApp(
      title: 'MemoLingvo',
      locale: locale,
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('en'), Locale('ru')],
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => _AuthGate(stream: _authStateChanges),
            );
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterScreen());
          case '/welcome':
            return MaterialPageRoute(builder: (context) => WelcomeScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => MainWrapper());
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(body: Text('Unknown route')),
            );
        }
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  final Stream<firebase_auth.User?> stream;

  const _AuthGate({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }

        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
          return Container();
        }

        return WelcomeScreen();
      },
    );
  }
}
