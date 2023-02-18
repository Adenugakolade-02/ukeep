import 'package:flutter/material.dart';
import 'package:ukeep/models/note.dart';
import 'package:ukeep/screens/noteEditor.dart';

class RouteGenerator{
  static Route<dynamic>? generateRoute(RouteSettings settings){
    if(settings.name ==null || settings.name!.isEmpty){
      return  null;
    }

    switch(settings.name){
      case '/editor':{
        final arguments = settings.arguments as Map;
        final note = arguments['note'] ?? Note(
          title: '', text: '', noteState: NoteState.others);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NoteEditorScreen(note: note,)
          );
      }
      default:
        return null;
    }
  }
}