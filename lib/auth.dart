import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';
// import 'firebase_options.dart';

class AuthScreens extends StatelessWidget {
  const AuthScreens({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          debugPrint("email ${snapshot.data?.email}");
          debugPrint("userid ${snapshot.data?.uid}");
          return const HomeScreen();
        } else {
          return SignInScreen(
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/google-keep.png'),
                ),
              );
            },
            providerConfigs: const [
              EmailProviderConfiguration(),
              GoogleProviderConfiguration(
                  clientId:
                      "586882765354-orh5e3iv5agqf29de0hqj4vf90dssqbq.apps.googleusercontent.com")
            ],
          );
        }
      });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: <Widget>[SignOutButton()]),
      body: Column(
        children: const [Text("Welcome to the home screen")],
      ),
    );
  }
}
