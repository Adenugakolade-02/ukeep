import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
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
final kDefaultNoteColor = kNoteColors.first;
    return Container(
      
    );
  }
}