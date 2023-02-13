import 'package:flutter/material.dart';
import 'package:collection_ext/iterables.dart';

import '../models.dart';
import 'note_item.dart';

class NoteList extends StatelessWidget {
  const NoteList({
    Key? key,
    required this.notes
  }):super(key:key);

  static NoteList create({
    Key? key,
    required List<Note?> notes,
  }) => NoteList(
    key: key,
    notes: notes
    );

  final List<Note?> notes;

  @override
  Widget build(BuildContext context) => SliverPadding(
  padding: const EdgeInsets.symmetric(horizontal: 10),
  sliver: SliverList(
    delegate: SliverChildListDelegate(
      notes.flatMapIndexed((index, note) => <Widget>[
        InkWell(
          onTap: (){},
          child: NoteItem(note: note!),
        ),
        if (index< notes.length -1) const SizedBox(height: 10,)
      ]).asList()
    ),
     ),
  );
}