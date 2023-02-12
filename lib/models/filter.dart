import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:ukeep/models/note.dart';

class FilterState extends ChangeNotifier{
 NoteState _noteState;

  NoteState get noteState => _noteState;

  set noteState (NoteState value){
    if(value !=null && value != _noteState){
      _noteState = value;
      notifyListeners();
    }
  }

  FilterState([this._noteState = NoteState.others]);
}