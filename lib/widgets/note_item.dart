import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:ukeep/imports/models.dart';

class NoteItem extends StatelessWidget {
  final Note note;

  const NoteItem({Key? key, required this.note}):super(key:key);

  @override
  Widget build(BuildContext context) => DefaultTextStyle(
    style: const TextStyle(
      color: Color(0xC2000000),
      fontSize: 14,
      height: 1.3125
    ),
    child: Container(
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (note.title.isNotEmpty ==true)
          Text(
            note.title,
            style: const TextStyle(
              color: Color(0xFF202124),
              fontSize: 16,
              height: 19 / 16,
              fontWeight: FontWeight.w500,
              ),
          ),
          if (note.title.isNotEmpty ==true) const SizedBox(height: 14,),
          Flexible(
            flex: 1,
            child: Text(note.text))
        ],
      ),
    )
    );
}