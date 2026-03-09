import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/core/localization/locale_cubit.dart';
import 'package:memo_lingvo/core/theme/theme_cubit.dart';
import 'package:memo_lingvo/features/auth/logic/auth_cubit.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/login_sreen.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/register_screen.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/splash_screen.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/welcome_screen.dart';
import 'package:memo_lingvo/features/home/presentation/screens/main_wrapper.dart';
import 'package:memo_lingvo/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/auth/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
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
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/home': (context) => MainWrapper(),
      },
      //home: SplashScreen(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final authRepository = AuthRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        BlocProvider(create: (context) => AuthCubit(authRepository)),
        BlocProvider(create: (context) => ThemeCubit(prefs)),
        BlocProvider(create: (context) => LocaleCubit(prefs)),
      ],
      child: MyApp(),
    ),
  );
}
