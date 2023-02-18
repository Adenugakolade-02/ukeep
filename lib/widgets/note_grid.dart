import 'package:flutter/material.dart';
import 'package:ukeep/imports/models.dart';
import 'package:ukeep/widgets/note_item.dart';

class NoteGrid extends StatelessWidget {
  const NoteGrid({
    Key? key,
    required this.notes, required this.onTap,
    }):super(key: key);

  final List<Note?> notes;
  final void Function(Note) onTap;

  static NoteGrid create ({
    Key? key,
    required List<Note?> notes,
    required void Function(Note) onTap
  }) => NoteGrid(
    key: key,
    notes: notes,
    onTap: onTap,
    );
  

  

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1 / 1.2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) =>  _noteItem(notes[index]!),
        childCount: notes.length
      ),
    ),
  );

  Widget _noteItem(Note note) => InkWell(
    onTap: ()=> onTap.call(note),
    child: NoteItem(note: note),
  );
}