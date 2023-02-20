import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukeep/imports/models.dart';
import 'package:collection_ext/iterables.dart';


class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    Note note = Provider.of<Note>(context);
    const Iterable<Color> kNoteColors = [
      Colors.white,
      Color(0xFFF28C82),
      Color(0xFFFABD03),
      Color(0xFFFFF476),
      Color(0xFFCDFF90),
      Color(0xFFA7FEEB),
      Color(0xFFCBF0F8),
      Color(0xFFAFCBFA),
      Color(0xFFD7AEFC),
      Color(0xFFFDCFE9),
      Color(0xFFE6C9A9),
      Color(0xFFE9EAEE),
    ];
    // final kDefaultNoteColor = kNoteColors.first;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kNoteColors.flatMapIndexed((i, color) => [
            if(i==0) const SizedBox(width: 17,),
            InkWell(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x21000000)),
                ),
                child: color==note.color ? const Icon(Icons.check, color: Color(0x21000000),) : null,
              ),
              onTap: (){
                if (color != note.color){
                  note.editNote(color: color);
                }
              },
            ),
            const SizedBox(width: 17,)
          ]).asList(),
      ),
    );
  }
}