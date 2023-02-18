import 'package:flutter/material.dart';
import 'package:collection_ext/iterables.dart';

import '../imports/models.dart';
import 'note_item.dart';

class NoteList extends StatelessWidget {
  const NoteList({
    Key? key,
    required this.notes, 
    required this.onTap
  }):super(key:key);

  static NoteList create({
    Key? key,
    required List<Note?> notes,
    required void Function(Note) onTap
  }) => NoteList(
    key: key,
    notes: notes,
    onTap: onTap,
    );

  final List<Note?> notes;
  final void Function(Note) onTap;
  
  @override
  Widget build(BuildContext context) => SliverPadding(
  padding: const EdgeInsets.symmetric(horizontal: 10),
  sliver: SliverList(
    delegate: SliverChildListDelegate(
      notes.flatMapIndexed((index, note) => <Widget>[
        InkWell(
          onTap: () => onTap.call(note),
          child: NoteItem(note: note!),
        ),
        if (index< notes.length -1) const SizedBox(height: 10,)
      ]).asList()
    ),
     ),
  );
}