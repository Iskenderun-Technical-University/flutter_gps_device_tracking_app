// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gps_device_tracking_app/firebase_options.dart';
import 'package:flutter_gps_device_tracking_app/screens/home_page.dart';
import 'package:flutter_gps_device_tracking_app/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

bool adminGirdi = false;
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final sp = await SharedPreferences.getInstance();

  final bool girisYapildi = sp.getBool('girisYapildi') ?? false;
  adminGirdi = sp.getBool('adminGirdi') ?? false;
  runApp(MyApp(girisYapildi));
}

class MyApp extends StatelessWidget {
  final bool? girisYapildi;
  const MyApp(this.girisYapildi, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        // dil işleme
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('es', 'ES'),
          Locale('tr', 'TR')
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: girisYapildi! ? const HomePage() : const WelcomePage());
  }
}
