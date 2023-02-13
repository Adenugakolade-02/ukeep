import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ukeep/models.dart';
import 'package:ukeep/widgets.dart';

class Homescren extends StatefulWidget {
  const Homescren({super.key});

  @override
  State<Homescren> createState() => _HomescrenState();
}

class _HomescrenState extends State<Homescren> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showGrid = true;
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<FilterState>(create: (_) => FilterState()),
            Consumer<FilterState>(
                builder: (context, filter, child) =>
                    StreamProvider<List<Note?>>.value(
                        value: _createNoteStream(context, filter),
                        initialData: [],
                        child: child))
          ],
          child: Consumer2<FilterState, List<Note>>(builder: (context, filter, notes, child){
            final hasNotes = notes.isEmpty != true;
            final canCreate = filter.noteState.canCreate;
            return Scaffold(
              key: _scaffoldKey,
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(width: 720),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      appBar(context, filter),
                      if(hasNotes) const SliverToBoxAdapter(
                        child: SizedBox(height: 24,),
                      ),
                      ...buildNoteView(filter,context,notes),
                      if (hasNotes) SliverToBoxAdapter(
                      child: SizedBox(height: (canCreate ? 56 : 10.0) + 10.0),
                    )
                    ],
                  ),
                ),
              ),
              floatingActionButton: canCreate ? actionButton(): null,
              bottomNavigationBar: bottomActions(),
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              extendBody: true,
            );
          }),
        ),
      );

  
  Widget appBar(BuildContext context, FilterState filter, ){
    return filter.noteState < NoteState.archieved
    ? SliverAppBar(
      floating: true,
      snap: true,
      title: topActions(),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    )
    : SliverAppBar(
      floating: true,
      snap: true,
      title: Text(filter.noteState.name),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  Widget topActions(){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 20,),
              InkWell(
                child: const Icon(Icons.menu,color: Colors.black,),
                onTap: () =>_scaffoldKey.currentState?.openDrawer(),
              ),
              const SizedBox(width: 16,),
              const Expanded(
                child: Text('Search for Notes',
                softWrap: false,
                style: TextStyle(
                  color: Color(0xFF61656A)
                ),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                child: Icon(Icons.list),
                onTap: (){},
              ),
              const SizedBox(width: 18,),
              buildAvatar(context),
              const SizedBox(width:10)
            ],
          ),
        ),
      )
    );
  }
  Widget buildAvatar(BuildContext context) {
    final user = Provider.of<UserData>(context).userD;
    return CircleAvatar(
      backgroundImage: user['url'] != null ? NetworkImage(user['url']!) : null,
      radius: 17,
      child: user['url'] == null? const Icon(Icons.face) : null,
    );
  }

  Widget actionButton() {
    return FloatingActionButton(
      onPressed: (){},
      backgroundColor: Color(0xFF7E39FB),
      child: Icon(Icons.add),
      );
  }

  Widget bottomActions() => BottomAppBar(
    shape: const CircularNotchedRectangle(),
    child: Container(
      height: 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const <Widget>[
          Icon(Icons.check_box, size: 26, color: Color(0xFF5F6368)),
          SizedBox(width: 30),
          Icon(Icons.brush_sharp, size: 26, color: Color(0xFF5F6368)),
          SizedBox(width: 30),
          Icon(Icons.mic, size: 26, color: Color(0xFF5F6368)),
          SizedBox(width: 30),
          Icon(Icons.insert_photo, size: 26, color: Color(0xFF5F6368)),
          SizedBox(width: 30)
        ],
      ),
    ),
  );
  List<Widget> buildNoteView(FilterState filterState, BuildContext context, List<Note?> notes){
    if(notes.isEmpty){
      return [buildBlankView(filterState.noteState)];
    }
    // return [buildBlankView(filterState.noteState)];
    final asGrid = filterState.noteState ==NoteState.deleted || _showGrid;
    final mode = asGrid? NoteGrid.create : NoteList.create;

    final showPinned = filterState.noteState == NoteState.others;

    if(!showPinned){
      return [mode(notes: notes)];
    }
    final partition = notesPartition(notes);
    final hasPinned = partition['PinnedPartition']!.isNotEmpty;
    final hasUnPinned = partition['OtherPartition']!.isNotEmpty;

    Widget labelBuilder(String label, [double top =26]) => SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 26,bottom: 25,top: top),
        child: Text(label, style: const TextStyle(
          color: Color(0xFF61656A),
          fontWeight: FontWeight.w500,
          fontSize: 12
          ),
        ),
      ),
    );
    return [
      if(hasPinned) labelBuilder('PINNED', 0),
      if(hasPinned) mode(notes: partition['PinnedPartition']!),
      if(hasPinned && hasUnPinned) labelBuilder('OTHERS'),
      mode(notes: partition['OtherPartition']!)
    ];
  }
  
  Widget buildBlankView(NoteState state) => SliverFillRemaining(
    hasScrollBody: false,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children:  <Widget>[
        const Expanded(child: SizedBox()),
        const Icon(
          Icons.push_pin,
          size: 120,
          color: Color(0xFF7E39FB),
          ),
          Expanded(
            flex: 2,
            child: Text(state.emptyResultMessage,
            style: const TextStyle(
              color: Color(0xFF61656A),
              fontSize: 14
            ),
          ),
        )
      ],
    ),
  );


  Stream<List<Note?>> _createNoteStream(BuildContext context, FilterState filter) {
    // return Stream<List<Note>>.empty();
    final user = Provider.of<UserData>(context).userD;
    final userUID = user['uid'] as String;
    final sinceSignUp = DateTime.now().millisecondsSinceEpoch-
      (user['metaData'].creationTime?.millisecondsSinceEpoch ?? 0);
    final useIndexes = sinceSignUp >= _10_mins_orderTime;
    final collection = userCollection(userUID);

    final fireQuery = filter.noteState == NoteState.others
      ? collection
        .where('noteState', isLessThan: NoteState.archieved.index)
        .orderBy('noteState', descending: true)
      : collection.where('noteState', isEqualTo: filter.noteState.index);

    return (useIndexes ? fireQuery.orderBy('createdAt',descending: true): fireQuery)
              .snapshots()
              .handleError((e) => debugPrint('Error in obtaining query $e'))
              .map((snapShot) => Note.fromQuery(snapShot));
  }           

  Map<String, List<Note?>> notesPartition(List<Note?> notes){
    if(notes.isEmpty){
      return {
        'PinnedPartition':[],
        'OtherPartition': []
      };
    }
    
   
    final indexUnpinned = notes.indexWhere((note) => note!.pinned);
    
    return indexUnpinned > -1
      ? {
        'PinnedPartition':notes.sublist(0,indexUnpinned),
        'OtherPartition': notes.sublist(indexUnpinned)
      }
      : {
        'PinnedPartition': notes,
        'OtherPartition': []
      };
  }

}
const _10_mins_orderTime = 60000;