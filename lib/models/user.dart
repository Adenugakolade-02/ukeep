import 'package:firebase_auth/firebase_auth.dart';

class UserData{
  final String uid;
  final String name;
  UserData(this.uid, this.name);

  factory UserData.fromFirebase(User user){
    return UserData(user.uid, user.email!.split('.')[0].toString());
  }

 

}