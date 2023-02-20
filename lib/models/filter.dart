import 'package:flutter/foundation.dart';
import 'package:ukeep/models/note.dart';

// creates a provider class used to filter notes into achieved, bin and home screens
class FilterState extends ChangeNotifier{
 NoteState _noteState;

  // calls the the current notestate
  NoteState get noteState => _noteState;

  // sets the current notestate
  set noteState (NoteState value){
    if(value != _noteState){
      _noteState = value;
      notifyListeners();
    }
  }

  // initializes the constructor and sets note state value to others
  FilterState([this._noteState = NoteState.others]);
}