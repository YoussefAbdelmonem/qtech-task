import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qtech_task/firebase_options.dart';

import 'core/services/bloc_observer.dart';
import 'features/pre_join_live/prejoin_live_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
  }
    Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.red, brightness: Brightness.dark),
      home: const PreJoinScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
