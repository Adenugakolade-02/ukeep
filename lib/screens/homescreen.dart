import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ukeep/imports/models.dart';
import 'package:ukeep/imports/widgets.dart';

class Homescren extends StatefulWidget{
  const Homescren({super.key});

  @override
  State<Homescren> createState() => _HomescrenState();
}

class _HomescrenState extends State<Homescren> with NoteCommandHandler{
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
          ], 
          child: Consumer<FilterState>(builder: (context, filter, child){
            final canCreate = filter.noteState.canCreate;
            return StreamBuilder<List<Note?>>(
              stream:  _createNoteStream(filter),
              builder: (context, snapshot) {
                return Scaffold(
                  key: _scaffoldKey,
                  body: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 720),
                      child: CustomScrollView(
                        slivers: <Widget>[
                          appBar(context, filter),
                          if(snapshot.hasData) const SliverToBoxAdapter(
                            child: SizedBox(height: 24,),
                          ),
                          if(snapshot.connectionState == ConnectionState.waiting)
                            const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(backgroundColor: Color(0xFF7E39FB),))),
                          if(snapshot.connectionState == ConnectionState.active)                            
                          ...buildNoteView(filter,context,snapshot.data!),
                          if (snapshot.hasData) SliverToBoxAdapter(
                          child: SizedBox(height: (canCreate ? 56 : 10.0) + 10.0),
                        )
                        ],
                      ),
                    ),
                  ),
                  drawer: const AppDrawer(),
                  floatingActionButton: canCreate ? actionButton(context): null,
                  bottomNavigationBar: bottomActions(),
                  floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
                  extendBody: true,
                );
              }
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
      backgroundColor: Colors.transparent,
      floating: true,
      snap: true,
      title: Text(
        filter.noteState.filterName,
        style: const TextStyle(
          color: Color(0xFF61656A),
          fontWeight: FontWeight.w300,
          letterSpacing: 1.3
        ),
        ),
      leading: IconButton(
        color: const Color(0xFF61656A),
        icon: const Icon(Icons.menu),
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
          padding: const EdgeInsets.symmetric(vertical: 5),
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
                child: Icon(
                  _showGrid? Icons.view_list: Icons.grid_view,
                  color: Colors.black,
                  ),
                onTap: (){
                  setState(() {
                    _showGrid = !_showGrid;
                  });
                },
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

  Widget actionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/editor'),
      backgroundColor: const Color(0xFF7E39FB),
      child: const Icon(Icons.add),
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
    final asGrid = filterState.noteState ==NoteState.deleted || _showGrid;
    final mode = asGrid? NoteGrid.create : NoteList.create;

    final showPinned = filterState.noteState == NoteState.others;

    if(!showPinned){
      return [mode(notes: notes, onTap: onTap)];
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
      if(hasPinned) mode(notes: partition['PinnedPartition']!, onTap: onTap),
      if(hasPinned && hasUnPinned) labelBuilder('OTHERS'),
      mode(notes: partition['OtherPartition']!, onTap: onTap)
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


  Stream<List<Note?>> _createNoteStream(FilterState filter) {
    final user = Provider.of<UserData>(context).userD;
    final userUID = user['uid'] as String;
    final userMetaData = user['metaData'] as UserMetadata;
    final sinceSignUp = DateTime.now().millisecondsSinceEpoch-
      (userMetaData.creationTime?.millisecondsSinceEpoch ?? 0);
    final useIndexes = sinceSignUp >= _10_mins_orderTime;
    final collection = userCollection(userUID);
    final fireQuery = filter.noteState == NoteState.others
      ? collection
        .where('noteState', isLessThan: NoteState.archieved.index)
        .orderBy('noteState', descending: true)
      : collection.where('noteState', isEqualTo: filter.noteState.index);
      

    return (fireQuery)
              .snapshots()
              .handleError((e) => debugPrint('Error in obtaining query $e'))
              .map((snapShot) => Note.fromQuery(query:snapShot));
  }           

  Map<String, List<Note?>> notesPartition(List<Note?> notes){
    if(notes.isEmpty){
      return {
        'PinnedPartition':[],
        'OtherPartition': []
      };
    }
    
   
    final indexUnpinned = notes.indexWhere((note) => !note!.pinned);
    debugPrint('Here is the index $indexUnpinned');
    
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

  void onTap(Note note) async{
    final command = await Navigator.pushNamed(context, '/editor', arguments: {'note':note});
    if(command != null){
      processCommand(_scaffoldKey.currentState!, command as NoteCommand);
    }
  }

}
const _10_mins_orderTime = 60000;