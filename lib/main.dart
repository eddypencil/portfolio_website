import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:portofilio_website/screens/desktop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Eddy's portofilio",
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> greetings = [
    "Hello",
    "Hola",
    "Bonjour",
    "Hallo",
    "Ciao",
  ];

  int _index = 0;
  Timer? _rotateTimer;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    _rotateTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _index = (_index + 1) % greetings.length;
      });
    });

    _redirectTimer = Timer(const Duration(seconds: 2), _goToMain);
  }

  void _goToMain() {
    _rotateTimer?.cancel();
    _redirectTimer?.cancel();

    Widget nextScreen = const MainScreen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  void dispose() {
    _rotateTimer?.cancel();
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToMain,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            greetings[_index],
            style: GoogleFonts.kalam(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}