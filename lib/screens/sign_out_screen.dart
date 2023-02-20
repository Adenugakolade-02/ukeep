import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class SignOut extends StatelessWidget {
  const SignOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: InkWell(
          child: const SignOutButton(),
          onTap: () => Navigator.pop(context),
          ),
      ),
      appBar: AppBar(
      ),
    );
  }
}