import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';


enum NoteState{
  others,
  pinned,
  archieved,
  deleted
}

extension NoteStateX on NoteState{
  bool get canCreate => this <= NoteState.pinned;
  bool get canEdit => this < NoteState.deleted;

  bool operator <(NoteState other) => (index) < (other.index);
  bool operator <=(NoteState other) => (index) <= (other.index);

  String get message {
    switch (this){
      case NoteState.archieved:
        return 'note archieved';
      case NoteState.deleted:
        return 'note moved to bin';
      default:
        return '';
    }
  }

  String get filterName{
    switch (this){
      case NoteState.archieved:
        return 'Archeive';
      case NoteState.deleted:
        return 'Bin';
      default:
        return '';
    }
  }
}


class Note{
  final String? id;
  final String title;
  final String text;
  final Color color;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final NoteState noteState;

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

  Map<String, dynamic> toJson() => {
    'title': title,
    'text':text,
    'color': color.value,
    'createdAt': createdAt.toString(),
    'modifiedAt': modifiedAt.toString(),
    'noteState': noteState.index
  };

  Note editNote({
    String? title,
    String? text,
    Color? color,
    NoteState? state
  }){
    return Note(
      title: title ?? this.title,  
      text: text ?? this.text, 
      color: color ?? this.color, 
      noteState: state ?? this.noteState,
      createdAt: createdAt,
      modifiedAt: DateTime.now()
      );
  }

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
  int get hashCode => id.hashCode ?? super.hashCode;
  

}
