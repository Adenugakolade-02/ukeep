import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukeep/imports/models.dart';
import 'package:ukeep/screens/homescreen.dart';


class AuthScreens extends StatelessWidget {
  const AuthScreens({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          debugPrint("email ${snapshot.data?.email}");
          debugPrint("userid ${snapshot.data?.uid}");
          debugPrint('${snapshot.data?.photoURL}');
          Provider.of<UserData>(context, listen: false).userSet = snapshot.data as User;
          return const Homescren();
        } else {
          return SignInScreen(
            headerBuilder: (context, constraints, shrinkOffset) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AspectRatio(
                    //   aspectRatio: 1,
                    //   child: Image.asset('assets/images/google-keep.png'),
                    // ),
                    // const SizedBox(width: 10,),
                    drawHeader()
                  ],
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

  Widget drawHeader(){
    return Padding(
      padding: const EdgeInsets.only(top:20, left: 30, right:30),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            color: Color(0xFF61656A),
            fontSize: 50,
            fontWeight: FontWeight.w300,
            letterSpacing: 2
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'U',
              style: TextStyle(
                color: Color(0xFF7E39FB),
                fontWeight: FontWeight.w500,
                // fontStyle: FontStyle.italic
              )
            ),
            TextSpan(text: 'Keep')
          ]
        ),
      ),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(actions: <Widget>[SignOutButton()]),
//       body: Column(
//         children: const [Text("Welcome to the home screen")],
//       ),
//     );
//   }
// }
