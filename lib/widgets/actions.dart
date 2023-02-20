import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukeep/imports/models.dart';

class NoteActions extends StatelessWidget {
  const NoteActions({super.key});

  @override
  Widget build(BuildContext context) {
    final note = Provider.of<Note>(context);
    final user = Provider.of<UserData>(context).userD;
    final uid = user['uid'] as String;

    const textStyle = TextStyle (
      color: Color(0xFF61656A),
      fontSize: 16,
    );

    final state = note.noteState;
    final id = note.id;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if(id!=null && state < NoteState.archieved)
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Archive', style: textStyle,),
            onTap: () => Navigator.pop(context, NoteCommand(
              id, 
              uid, 
              state, 
              NoteState.archieved,
              true
              )),
          ),
        if(state == NoteState.archieved)
          ListTile(
            leading: const Icon(Icons.unarchive_outlined),
            title: const Text('Unarchive', style: textStyle,),
            onTap: () => Navigator.pop(context, NoteCommand(
              id!, 
              uid, 
              state, 
              NoteState.others,
              )),
          ),
        if(id!=null && state != NoteState.deleted)
          ListTile(
            leading: const Icon(Icons.delete_outlined),
            title: const Text('Bin', style: textStyle,),
            onTap: () => Navigator.pop(context, NoteCommand(
              id, 
              uid, 
              state, 
              NoteState.deleted,
              true
              )),
          ),
        if(state==NoteState.deleted)
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore', style: textStyle,),
            onTap: () => Navigator.pop(context, NoteCommand(
              id!, 
              uid, 
              state, 
              NoteState.others,
              true
              )),
          )
      ],
    );
  }
}