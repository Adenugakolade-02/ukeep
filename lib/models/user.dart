import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// creates a user data class 
class UserData extends ChangeNotifier{
  String uid;
  String name;
  String photoURL;
  UserMetadata? metadata;

  Map<String, dynamic> get userD => {
    'uid': uid,
    'name': name,
    'photoUrl': photoURL,
    'metaData': metadata
  };

  // creates class constructor using setter
  set userSet(User user){
    uid = user.uid;
    name = user.email!.split('.')[0].toString();
    photoURL = user.photoURL ?? '';
    metadata = user.metadata;
  }

    UserData([this.uid='', this.name='', this.photoURL='']);
  }