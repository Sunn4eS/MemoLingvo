import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:memo_lingvo/app_providers.dart';
import 'package:memo_lingvo/auth_gate.dart';
import 'package:memo_lingvo/core/database/app_database.dart';

import 'package:memo_lingvo/firebase_options.dart';
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
