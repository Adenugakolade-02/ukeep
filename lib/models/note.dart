import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:ukeep/models/transactions.dart';


enum NoteState{
  others,
  pinned,
  archieved,
  deleted
}

extension NoteStateX on NoteState{
  bool get canCreate => this <= NoteState.pinned;
  bool get canEdit => this < NoteState.deleted;

  bool operator < (NoteState other) => (index) < (other.index);
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

  Note editNote({
    String? title,
    String? text,
    Color? color,
    NoteState? state
  }){
    notifyListeners();
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
