import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Profile Components/Logine.dart';
import 'BottomNavigator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    Timer(const Duration(seconds: 2), () {
      if (user == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const BottomNavigatorExample()),
            (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            user = snapshot.data;
            return Scaffold(
              backgroundColor: Colors.white,
              body:
                  Center(child: Image.asset("assets/app_icon.png", scale: 1.5)),
              bottomSheet: Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  color: Colors.white,
                  child: Image.asset("assets/splash_image.png", scale: 2)),
            );
            // if (user == null) {
            //   return LoginPage();
            // } else {
            //   return BottomNavigatorExample();
            // }
          } else {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
