import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // late StreamSubscription<Note> _noteSubscription;

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
    _originNote = _note.copy();
    
    _titleEditingController = TextEditingController(text: _note.title);
    _textEditingController = TextEditingController(text: _note.text);

    _titleEditingController.addListener(() =>_note.title = _titleEditingController.text);
    _textEditingController.addListener(() =>_note.text = _textEditingController.text);
    super.initState();
  }

  @override
  void dispose() {
    // _noteSubscription.cancel();
    _titleEditingController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<UserData>(context).userD['uid'] as String;
    return ChangeNotifierProvider.value(
      value: _note,
      child: Consumer<Note>(
        builder: (_,__,___) => Hero(
          tag: 'Note${_note.id}', 
          child: Theme(
            data: Theme.of(context).copyWith(
              primaryColor: _noteColor,
              scaffoldBackgroundColor: _noteColor,
              appBarTheme: Theme.of(context).appBarTheme.copyWith(
                elevation: 0,
                iconTheme: const IconThemeData(
                  color: Color(0xFF5F6368)
                )
              )
            ),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: _noteColor,
                systemNavigationBarColor: _noteColor,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  actions: buildTopActions(uid),
                  bottom: const PreferredSize(
                    preferredSize: Size(0,24),
                    child: SizedBox()),
                  backgroundColor: _noteColor,

                ),
                body: buildBody(context, uid),
                bottomNavigationBar: buildBottomAppBar(context,uid),
              ),
            ),
          )
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, String uid){
    return DefaultTextStyle(
      style: const TextStyle(
        color: Color(0xC2000000),
        fontSize: 18,
        height: 1.3125,
      ), 
      child: WillPopScope(
        onWillPop: ()=>_onPop(uid),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: buildNoteDetails(),
          ),
        ),
      )
    );
  }

  Widget buildNoteDetails(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _titleEditingController,
          style: _formStyle,
          decoration: const InputDecoration(
            hintText: 'Title',
            border: InputBorder.none,
          ),
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          readOnly: !_note.noteState.canEdit,
        ),
        const SizedBox(height: 14,),
        TextField(
          controller: _textEditingController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Text'
          ),
          style: const TextStyle(
            color: Color(0xC2000000),
            fontSize: 18,
            height: 1.3
          ),
          textCapitalization: TextCapitalization.sentences,
          readOnly: !_note.noteState.canCreate,
        )
      ],
    );
  }

  List<Widget> buildTopActions(String uid) => [
    if(_note.noteState < NoteState.deleted)
      IconButton(
        onPressed: () => updateNoteState(uid, _note.pinned ? NoteState.others: NoteState.pinned), 
        icon: Icon(_note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
        color: const Color(0xFF5F6368),
        )
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
        icon: const Icon(Icons.archive_outlined, color: Color(0xFF5F6368),)),
    if(_note.noteState == NoteState.archieved)
      IconButton(
        onPressed: () => updateNoteState(uid, NoteState.others), 
        icon: const Icon(Icons.unarchive_outlined, color: Color(0xFF5F6368),)
        )
  ];

  Future<bool> _onPop(String uid)async {
    if(_isDirty){
       _note.modifiedAt = DateTime.now();
        await _note.noteToFirestore(uid);
      _originNote = _note;
    }
    return Future.value(true);
  }

  Widget buildBottomAppBar(BuildContext context, String uid) =>
    BottomAppBar(
      child: Container(
        height: 56,
        color: _noteColor,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              onPressed: _note.noteState.canEdit 
              ? () async{
                if(_isDirty){
                  _note.modifiedAt = DateTime.now();
                  await _note.noteToFirestore(uid);
                  _originNote = _note;
                }
                // await _note.noteToFirestore(uid);
              } 
              : null, 
              color: const Color(0xFF5F6368),
              icon: const Icon(Icons.add_box)
              ),
            IconButton(
              onPressed: ()=>showBottomSheet(context),
              icon: const Icon(Icons.more_vert)
            )
          ],
        ),
      ),
    );

  void showBottomSheet(BuildContext context) async{
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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const NoteActions(),
                if(_note.noteState.canEdit) const SizedBox(height: 16,),
                if(_note.noteState.canEdit) const ColorPicker(),
                const SizedBox(height:12)
              ],
            ),
          )
        )
      )
      );
      if(command != null){
        if(command.dismiss){
          // ignore: use_build_context_synchronously
          Navigator.pop(context, command);
        }
        else {
          processCommand(_scaffoldKey.currentState!,command);
        }
      }
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