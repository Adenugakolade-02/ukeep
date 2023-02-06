import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';


enum NoteState{
  archived,
  others,
  deleted,
  pinned
}

class Note{
  final String id;
  final String title;
  final String text;
  final Color color;
  DateTime? createdAt;
  DateTime? modifiedAt;
  final NoteState noteState;

  Note({required this.title, 
        required this.id, 
        required this.text, 
        required this.color,
        required this.noteState,
        DateTime? createdAt, 
        DateTime? modifiedAt, 
        }): 
              this.createdAt= createdAt ?? DateTime.now(),
              this.modifiedAt = modifiedAt ?? DateTime.now();

  factory Note.fromFirebase(QueryDocumentSnapshot _snapShot){
    return Note(
      title:_snapShot.get('title'),
      id: _snapShot.get('id'),
      text: _snapShot.get('text'), 
      color: Color(_snapShot.get('color') as int) , 
      createdAt:_snapShot.get('createdAt'),
      modifiedAt:_snapShot.get('modifiedAt'),
      noteState: NoteState.values[_snapShot.get('noteState')]
      );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'id': id,
    'text':text,
    'color': color.toString(),
    'createdAt': createdAt.toString(),
    'modifiedAt': modifiedAt.toString(),
    'noteState': noteState.index
  };

  Note editNote(
    String? title,
    String? text,
    Color? color,
    NoteState? state
  ){
    return Note(
      title: title ?? this.title, 
      id: id , 
      text: text ?? this.text, 
      color: color ?? this.color, 
      noteState: state ?? this.noteState,
      createdAt: createdAt,
      modifiedAt: DateTime.now()
      );
  }


}
