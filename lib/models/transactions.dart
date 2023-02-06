import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ukeep/models/note.dart';

class FireTransactions extends ChangeNotifier{
  final String uid;
  
  FireTransactions(this.uid){
    userCollection = FirebaseFirestore.instance;
    reference = userCollection.collection('note-$uid');
  }
  
  late FirebaseFirestore userCollection;
  late CollectionReference reference;
  
  // Remeber to show snackbar after document has been stored or updated
  void storeNewData(Note note){
    reference.add(note.toJson());
    notifyListeners();
  }

  void updateData(Map<String, dynamic> newData,String id){
    final docRef = reference.doc(id);
    userCollection.runTransaction((transaction) async{
      // final snapShot = await transaction.get(docRef);
      transaction.update(docRef, newData);
    });
    notifyListeners();
  }

 
  void updateState(String id, NoteState state){
    final docRef = reference.doc(id);
    userCollection.runTransaction((transaction) async{
      final snapShot = await transaction.get(docRef);
      transaction.update(docRef, 
      {'noteState': NoteState.values[snapShot.get('noteState')],
        'modifiedAt': DateTime.now().toString()
      });
    });
    notifyListeners();
  }

}