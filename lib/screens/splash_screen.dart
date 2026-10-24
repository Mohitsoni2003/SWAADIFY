import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/swaadify_logo.png", height: 160),

            const SizedBox(height: 25),

            Text(
              "SWAADIFY",
              style: GoogleFonts.mynerve(
                fontStyle: FontStyle.italic,
                fontSize: 29,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: const Color.fromARGB(255, 17, 157, 10),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Swaad bhi, Sehat bhi!",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Color(0xFF6D4C41),
              ),
            ),

            const SizedBox(height: 35),

            const CircularProgressIndicator(color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }
}
