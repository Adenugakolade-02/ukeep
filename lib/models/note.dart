import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ukeep/models/transactions.dart';


enum NoteState{
  others,
  pinned,
  archieved,
  deleted
}

extension NoteStateX on NoteState{
  // Checks if the current screen can create a new note
  bool get canCreate => this <= NoteState.pinned;
  
  // checks if the current note can Achievebe edited
  bool get canEdit => this < NoteState.deleted;

  // creates a boolean operator to compare note states
  bool operator < (NoteState other) => (index) < (other.index);
  bool operator <=(NoteState other) => (index) <= (other.index);

  String get message {
    switch (this){
      case NoteState.archieved:
        return 'note archived';
      case NoteState.deleted:
        return 'note moved to bin';
      default:
        return '';
    }
  }

  String get filterName{
    switch (this){
      case NoteState.archieved:
        return 'Archived';
      case NoteState.deleted:
        return 'Bin';
      default:
        return '';
    }
  }
  String get emptyResultMessage {
    switch (this) {
      case NoteState.archieved:
        return 'Archived notes appear here';
      case NoteState.deleted:
        return 'Notes in trash appear here';
      default:
        return 'Notes you add appear here';
    }
  }
}


class Note extends ChangeNotifier{
  String? id;
  String title;
  late  String text;
  Color color;
  DateTime createdAt;
  DateTime modifiedAt;
  NoteState noteState;

  Note({required this.title,  
        required this.text, 
        required this.noteState,
        Color? color,
        this.id,
        DateTime? createdAt, 
        DateTime? modifiedAt, 
        }): 
              createdAt= createdAt ?? DateTime.now(),
              modifiedAt = modifiedAt ?? DateTime.now(),
              color = color ?? Colors.white;

  // obtains a list of notes from firestore document snapshot
  static List<Note?> fromQuery({QuerySnapshot? query}) => query!=null? query.toNotes() : [];

  bool get pinned => noteState == NoteState.pinned;

  Map<String, dynamic> toJson() => {
    'title': title,
    'text':text,
    'color': color.value,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'modifiedAt': modifiedAt.millisecondsSinceEpoch,
    'noteState': noteState.index
  };

  // updates the note parameters
  Note editNote({
    String? title,
    String? text,
    Color? color,
    NoteState? state
  }){
    if (title != null) this.title = title;
    if (text != null) this.text = text;
    if (color != null) this.color = color;
    if (state != null) this.noteState = state;
    notifyListeners();
    return this;
  
  }

  // creates a  note copy
  Note copy(){
    return Note
    (title: title, 
    text: text, 
    noteState: noteState, 
    id: id,
    createdAt: createdAt,
    color: color,
    modifiedAt: modifiedAt
    );
  }

  void update(Note other){
    title = other.title;
    text = other.text;
    color = other.color;
    noteState = other.noteState;
    modifiedAt = other.modifiedAt;
    notifyListeners();
  }

  // construct and equality operator for comparing note
  @override
  bool operator ==(other) => other is Note &&
  other.id == id &&
  other.title == title &&
  other.text == text &&
  other.noteState == noteState &&
  other.color == color &&
  other.createdAt == createdAt &&
  other.modifiedAt == modifiedAt;
  
  @override
  int get hashCode => id.hashCode;
  
  
}
