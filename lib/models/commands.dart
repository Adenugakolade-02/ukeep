import 'package:flutter/foundation.dart';
import 'package:ukeep/models.dart';

@immutable
abstract class INotecommand{
  void execute();
  void getTitle() => '';
  void undo();
}


class NoteCommand implements INotecommand{
    
  final String id;
  final String uid;
  final NoteState from;
  final NoteState to;
  
  NoteCommand(
    this.id,
    this.uid,
    this.from,
    this.to
  );
  @override
  void execute() {
    // TODO: implement execute
  }

  @override
  void getTitle() {
    // TODO: implement getTitle
  }

  @override
  void undo() {
    // TODO: implement undo
  }

}

