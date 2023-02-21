import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ukeep/models/note.dart';

// creates an abstract class to implement command pattern
abstract class INotecommand{
  Future<void> execute();
  String getTitle() => '';
  Future<void> undo();
  Future<void> delete();
}

// Implements the abstract class INoteCommand
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
  
  // calls the execute function to update the note state on the firestore
  @override
  Future<void> execute() => updateNoteState(to, id, uid);

  // creates a message function to send the name of the operation being carried out 
  @override
  String getTitle() {
    switch(to){

      case NoteState.deleted:
        return "Note has been moved to Bin";
      case NoteState.pinned:
        return from == NoteState.archieved
          ? "Note pinned and unarchived"
          : '';
      case NoteState.archieved:
        return "Note Archived";
      default:
        switch (from){

          case NoteState.deleted:
            return "Note has been moved from trash";
          case NoteState.archieved:
            return "Note has been unarchived";
          case NoteState.pinned:
            return "Note has been unpinned";
          default:
            return '';
        }
    }
  }

  // creates an undo function for each operation carried out 
  @override
  Future<void> undo() => updateNoteState(from, id, uid);

  @override
  Future<void> delete() => deleteDocument(uid, id);
}

// creates a mixin that can be extended by all stateful widget 
mixin NoteCommandHandler<T extends StatefulWidget> on State<T>{
  
  // Executes the note command passed to it
  // pops up a scaffold messanger stating the operation carried out
  // displays a undo text button to  revert the executed command 
  Future<void> processCommand(ScaffoldState scaffoldState, NoteCommand noteCommand) async{
    if(noteCommand.from == noteCommand.to){
      await noteCommand.delete();
    }
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
  // instantiates the user fire store collection
  final collection = userCollection(uid);
  // creates a new firestore instance
  final instance = fireInstance();
  // gets the current document being edited
  final docReference = collection.doc(id);
  return id == null 
  ? await collection.add(toJson()) 
  : await instance.runTransaction((transaction) async{
      debugPrint('Instantiated connection');
      transaction.update(docReference, toJson());
  });
 }  
}



// converts a firestore document snapshot to a instance of a note
extension FromFireStore on DocumentSnapshot{
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

// updates the note state in the firestore
Future<void> updateNoteState(NoteState state, String id, String uid){
  return updateNote({'noteState':state.index}, id, uid);
}

Future<void> updateNote(Map<String, dynamic> data, String id, String uid){
  return noteDocument(uid, id).update(data);
}

Future<void> deleteDocument(String uid, String id){
  return noteDocument(uid, id).delete();
}