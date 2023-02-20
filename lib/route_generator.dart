import 'package:flutter/material.dart';
import 'package:ukeep/models/note.dart';
import 'package:ukeep/screens/noteEditor.dart';
import 'package:ukeep/screens/sign_out_screen.dart';

class RouteGenerator{
  static Route<dynamic>? generateRoute(RouteSettings settings){
    if(settings.name ==null || settings.name!.isEmpty){
      return  null;
    }

    switch(settings.name){
      case '/editor':{
        // final arguments = settings.arguments ??;
        final arguments = settings.arguments == null? {}: settings.arguments as Map;
        final note = arguments['note'] ?? Note(
          title: '', text: '', noteState: NoteState.others);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NoteEditorScreen(note: note,)
          );
      }
      case '/signout':
        return MaterialPageRoute(
          builder: (_) => const SignOut()
          );
      default:
        return null;
    }
  }
}