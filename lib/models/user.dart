import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserData extends ChangeNotifier{
  String uid;
  String name;
  String photoURL;
  UserMetadata? metadata;
  // UserData({String? uid, String? name, String? photoUrl}):
                                                // uid=uid??'', 
                                                // name=name??'', 
                                                // photoURL=photoUrl;

  // factory UserData.fromFirebase(User user){
  //   return UserData(
  //     uid:user.uid, 
  //     name:user.email!.split('.')[0].toString(),
  //     photoUrl: user.photoURL);
  Map<String, dynamic> get userD => {
    'uid': uid,
    'name': name,
    'photoUrl': photoURL,
    'metaData': metadata
  };

  set userSet(User user){
    uid = user.uid;
    name = user.email!.split('.')[0].toString();
    photoURL = user.photoURL ?? '';
    metadata = user.metadata;
    // debugPrint('here is username $name');
  }

    UserData([this.uid='', this.name='', this.photoURL='']);
  }