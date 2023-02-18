import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukeep/imports/models.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) => Consumer<FilterState>(
    builder: (context, filter,_) => Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          drawHeader(),
          const SizedBox(height: 25,),
          DrawerItem(
            iconData: Icons.push_pin, 
            title: 'Notes', 
            isChecked: filter.noteState == NoteState.others, 
            onTap: (){
              filter.noteState = NoteState.others;
              Navigator.pop(context);
            }),
          const Divider(),
          DrawerItem(
            iconData: Icons.archive_outlined, 
            title: 'Archieved', 
            isChecked: filter.noteState == NoteState.archieved, 
            onTap: (){
              filter.noteState = NoteState.archieved;
              Navigator.pop(context);
            }),
            DrawerItem(
            iconData: Icons.archive_outlined, 
            title: 'Bin', 
            isChecked: filter.noteState == NoteState.deleted, 
            onTap: (){
              filter.noteState = NoteState.deleted;
              Navigator.pop(context);
            }),
          DrawerItem(
            iconData: Icons.settings_outlined, 
            title: 'Settings', 
            onTap: (){}
            ),
          DrawerItem(
            iconData: Icons.help_center_outlined, 
            title: 'About Project', 
            onTap: (){})
        ],
      )
    )
  );


  Widget drawHeader(){
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top:20, left: 30, right:30),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              color: Color(0xFF61656A),
              fontSize: 26,
              fontWeight: FontWeight.w300,
              letterSpacing: 2
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'U',
                style: TextStyle(
                  color: Color(0xFF7E39FB),
                  fontWeight: FontWeight.w500,
                  // fontStyle: FontStyle.italic
                )
              ),
              TextSpan(text: 'Keep')
            ]
          ),
        ),
      )
    );
  }
}




class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key, 
    required this.iconData, 
    required this.title, 
    this.iconSize = 26, 
    this.isChecked = false, 
    required this.onTap});

  final IconData iconData;
  final String title;
  final double iconSize;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end:12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: ShapeDecoration(
            color: isChecked? const Color(0x337E39FB): Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              )
            )
          ),
          padding: const EdgeInsetsDirectional.only(
            top:12.5, bottom: 12.5, start: 30, end:18
          ),
          child: item(),
        ),
      ),
    );
  }

  Widget item() => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      if(iconData!=null) Icon(iconData,
      size: iconSize,
      color: isChecked ? Color(0xFF202124) : Color(0xFF5F6368),
      ),
      const SizedBox(width: 20,),
      Text(title,
      style: const TextStyle(
        color: Color(0xFF202124),
        fontSize: 16
      ),
      )
    ],
  );
}
