import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:herb_identifier/firebase_options.dart';
import 'package:herb_identifier/pages/homePage.dart';
import 'package:herb_identifier/pages/splash_screen.dart';
import 'package:herb_identifier/pages/RegisterScreen.dart';
import 'package:herb_identifier/pages/LoginPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await dotenv.load();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //title: 'Herb Identifier',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}
