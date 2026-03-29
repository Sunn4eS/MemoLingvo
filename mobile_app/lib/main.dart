import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:memo_lingvo/app_providers.dart';
import 'package:memo_lingvo/auth_gate.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/core/localization/locale_cubit.dart';
import 'package:memo_lingvo/core/theme/theme_cubit.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/login_sreen.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/register_screen.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/splash_screen.dart';
import 'package:memo_lingvo/features/auth/presentation/screens/welcome_screen.dart';
import 'package:memo_lingvo/features/home/presentation/screens/main_wrapper.dart';
import 'package:memo_lingvo/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final database = AppDatabase();
  final prefs = await SharedPreferences.getInstance();
  //final authRepository = AuthRepository();

  runApp(
    AppProviders(
      child: MyApp(), 
      database: database, 
      prefs: prefs
    ),
  );
}
