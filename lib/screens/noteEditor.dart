import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../imports/models.dart';
import '../imports/widgets.dart';


class NoteEditorScreen extends StatefulWidget {
  final Note note;
  const NoteEditorScreen({super.key, required this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> with NoteCommandHandler{
  late Note _note;
  late Note _originNote;
  late TextEditingController _titleEditingController;
  late TextEditingController _textEditingController;
  late StreamSubscription<Note> _noteSubscription;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool get _isDirty => _note != _originNote;
  Color get _noteColor => _note.color;

  final _formStyle = const TextStyle(
  color: Color(0xFF202124),
  fontSize: 21,
  height: 19 / 16,
  fontWeight: FontWeight.w500,
);

  @override
  void initState() {
    _note = widget.note;
    _originNote = widget.note;
    
    _titleEditingController = TextEditingController(text: _note.title);
    _textEditingController = TextEditingController(text: _note.text);

    _titleEditingController.addListener(() =>_note.title = _titleEditingController.text);
    _textEditingController.addListener(() =>_note.text = _textEditingController.text);
    super.initState();
  }

  @override
  void dispose() {
    _noteSubscription.cancel();
    _titleEditingController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget buildBody(){
    return Container();
  }

  Widget buildNoteDetails(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _titleEditingController,
          style: _formStyle,
          decoration: const InputDecoration(
            hintText: 'title',
            border: InputBorder.none,
          ),
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          readOnly: _note.noteState.canEdit,
        ),
        const SizedBox(height: 14,),
        TextField(
          controller: _textEditingController,
          style: const TextStyle(
            color: Color(0xC2000000),
            fontSize: 18,
            height: 1.3
          ),
          textCapitalization: TextCapitalization.sentences,
          readOnly: _note.noteState.canCreate,
        )
      ],
    );
  }

  List<Widget> buildTopActions(String uid) => [
    if(_note.noteState < NoteState.deleted)
      IconButton(
        onPressed: () => updateNoteState(uid, _note.pinned ? NoteState.others: NoteState.pinned), 
        icon: Icon(_note.pinned ? Icons.pin : Icons.pin_outlined)
      ),
    if(_note.id != null && _note.noteState < NoteState.archieved)
      IconButton(
        onPressed: ()=>Navigator.pop(
          context,
          processCommand(_scaffoldKey.currentState!, 
          NoteCommand(
            _note.id!, 
            uid, 
            _note.noteState, 
            NoteState.archieved)
          )
        ), 
        icon: const Icon(Icons.archive_outlined)),
    if(_note.noteState == NoteState.archieved)
      IconButton(
        onPressed: () => updateNoteState(uid, NoteState.others), 
        icon: const Icon(Icons.unarchive_outlined)
        )
  ];

  Future<bool> _onPop(String uid)async {
    if(_isDirty){
      _note
        ..modifiedAt = DateTime.now()
        ..noteToFirestore(uid);
      _originNote = _note;
    }
    return Future.value(true);
  }

  Widget buildBottomAppBar() =>
    BottomAppBar(
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              onPressed: _note.noteState.canEdit ? (){} : null, 
              color: Color(0xFF5F6368),
              icon: const Icon(Icons.add_box)
              ),
            IconButton(
              onPressed: (){},
              icon: const Icon(Icons.more_vert)
            )
          ],
        ),
      ),
    );

  void showBottomSheet() async{
    final command = await showModalBottomSheet<NoteCommand>(
      backgroundColor: _noteColor,
      context: context, 
      builder: (context) => ChangeNotifierProvider.value(
        value: _note,
        child: Consumer<Note>(builder: (_, note, __) => 
          Container(
            color: note.color,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              children: <Widget>[
                NoteActions(),
                if(_note.noteState.canEdit)
                  const SizedBox(height: 16,)
                
              ],
            ),
          )
        )
      )
      );
  }

  void updateNoteState(String uid, NoteState state){
    // checks if it is newly created note and updates it locally
    if(_note.id == null){
     _note.editNote(state: state);
     return; 
    }

    processCommand(_scaffoldKey.currentState!, NoteCommand(
      _note.id!, 
      uid , 
      _note.noteState, 
      state
      ));
  }
}