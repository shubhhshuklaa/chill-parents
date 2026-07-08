import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/splash.dart';
import 'firebase_options.dart';

/// 👉 (Optional future use) background service init yahan attach hoga
/// abhi empty rakha hai taaki app crash na ho
Future<void> initializeSOSService() async {

  // Future: FlutterBackgroundService init yahan lagega
  // Abhi empty safe function
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // SOS / Background service hook (future-ready)
  await initializeSOSService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chill Parents',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}