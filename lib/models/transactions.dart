import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ukeep/models/note.dart';

@immutable
abstract class INotecommand{
  Future<void> execute();
  String getTitle() => '';
  Future<void> undo();
}


class NoteCommand implements INotecommand{
    
  final String id;
  final String uid;
  final NoteState from;
  final NoteState to;
  bool dismiss;
  
  NoteCommand(
    this.id,
    this.uid,
    this.from,
    this.to,
    [this.dismiss = false] 
  );
  
  @override
  Future<void> execute() => updateNoteState(to, id, uid);

  @override
  String getTitle() {
    switch(to){

      case NoteState.deleted:
        return "Note has been moved to Bin";
      case NoteState.pinned:
        return "Note pinned";
      case NoteState.archieved:
        return "Note Archieved";
      default:
        switch (from){

          case NoteState.deleted:
            return "Note has been moved from trash";
          case NoteState.archieved:
            return "Note has benn unarchieved";
          case NoteState.pinned:
            return "Note has been unpinned";
          default:
            return '';
        }
    }
  }

  @override
  Future<void> undo() => updateNoteState(from, id, uid);
}

// using scaffold messenger to revert changes,
mixin NoteCommandHandler<T extends StatefulWidget> on State<T>{
  
  Future<void> processCommand(ScaffoldState scaffoldState, NoteCommand noteCommand) async{
    await noteCommand.execute();
    final commandMessage = noteCommand.getTitle();
    if(mounted && commandMessage.isNotEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(commandMessage),
          action: SnackBarAction(
            label: 'Undo', 
            onPressed: ()async{
              return await noteCommand.undo();
              }),
          )
      );
    }
  }
}

extension NoteQuery on QuerySnapshot {
  /// Transforms the query result into a list of notes.
  List<Note?> toNotes() => docs.map((d) => d.toNote()).toList();
}

extension FireTransaction on Note{
 Future<dynamic> noteToFirestore(String uid) async{
  debugPrint('arrived here connection');
  final collection = userCollection(uid);
  final instance = fireInstance();
  final docReference = collection.doc(id);
  return id == null 
  ? await collection.add(toJson()) 
  : await instance.runTransaction((transaction) async{
      debugPrint('Instantiated connection');
      transaction.update(docReference, toJson());
  });
 }  
}




extension FromFireStore on QueryDocumentSnapshot{
  Note toNote(){
    final Map<String, dynamic>  data = this.data() as Map<String, dynamic>;
    return Note(
      id: id,
      title: data['title'],
      text: data['text'], 
      color: Color(data['color']) , 
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(data['modifiedAt']),
      noteState: NoteState.values[data['noteState']]
      );
  } 
}



CollectionReference userCollection (String uid) => FirebaseFirestore.instance.collection(uid);
FirebaseFirestore  fireInstance()=> FirebaseFirestore.instance;
DocumentReference noteDocument(String uid, String id) => userCollection(uid).doc(id);

Future<void> updateNoteState(NoteState state, String id, String uid){
  return updateNote({'noteState':state.index}, id, uid);
}

Future<void> updateNote(Map<String, dynamic> data, String id, String uid){
  return noteDocument(uid, id).update(data);
}