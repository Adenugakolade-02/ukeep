import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ukeep/models/note.dart';

// class FireTransactions extends ChangeNotifier{
//   final String uid;
  
//   FireTransactions(this.uid){
//     userCollection = FirebaseFirestore.instance;
//     reference = userCollection.collection('note-$uid');
//   }
  
//   late FirebaseFirestore userCollection;
//   late CollectionReference reference;
  
//   // Remeber to show snackbar after document has been stored or updated
//   void storeNewData(Note note){
//     reference.add(note.toJson());
//     notifyListeners();
//   }

//   void updateData(Map<String, dynamic> newData,String id){
//     final docRef = reference.doc(id);
//     userCollection.runTransaction((transaction) async{
//       // final snapShot = await transaction.get(docRef);
//       transaction.update(docRef, newData);
//     });
//     notifyListeners();
//   }

 
//   void updateState(String id, NoteState state){
//     final docRef = reference.doc(id);
//     userCollection.runTransaction((transaction) async{
//       final snapShot = await transaction.get(docRef);
//       transaction.update(docRef, 
//       {'noteState': NoteState.values[snapShot.get('noteState')],
//         'modifiedAt': DateTime.now().toString()
//       });
//     });
//     notifyListeners();
//   }

// }

extension NoteQuery on QuerySnapshot {
  /// Transforms the query result into a list of notes.
  List<Note?> toNotes() => docs.map((d) => d.toNote()).toList();
}

extension FireTransaction on Note{
 Future<dynamic> noteToFirestore(String uid){
  final collection = userCollection(uid);
  final instance = fireInstance();
  final docReference = collection.doc(id);
  return id == null 
  ? collection.add(toJson()) 
  : instance.runTransaction((transaction) async{
      transaction.update(docReference, toJson());
  });
 }  
}




extension FromFireStore on QueryDocumentSnapshot{
  Note toNote(){
    // if (!exists) return null;
    final data = this.data() as QueryDocumentSnapshot<Object?>;
    return Note(
      id: id,
      title: data.get('title'),
      text: data.get('text'), 
      color: Color(data.get('color')) , 
      createdAt: DateTime.fromMillisecondsSinceEpoch(data.get('createdAt')),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(data.get('modifiedAt')),
      noteState: NoteState.values[data.get('noteState')]
      );
  } 
}



CollectionReference userCollection (String uid) => FirebaseFirestore.instance.collection(uid);
FirebaseFirestore  fireInstance()=> FirebaseFirestore.instance;
DocumentReference noteDocument(String uid, String id) => userCollection(uid).doc(id);

