import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Components/shimmer.dart';
import 'package:vichaar/View/conversationsScreen.dart';
import 'package:vichaar/constant.dart';

import '../Components/noteTile.dart';
import '../Model/noteModel.dart';
import '../Services/apiServices.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Note>> notesForYou;
  late Future<List<Note>> notesFollowing;
  late String userID;
  final ScrollController _scrollControllerForYou = ScrollController();
  final ScrollController _scrollControllerFollowing = ScrollController();
  int _pageForYou = 1;
  int _pageFollowing = 1;
  bool _isFetchingForYou = false;
  bool _isFetchingFollowing = false;

  @override
  void initState() {
    super.initState();
    notesForYou = apiService.getNotes();
    notesFollowing = apiService.getFollowingNotes();

    
    fetchUserID();
  }

  Future<void> fetchUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID') ?? "N/A";
  }

  Future<void> _refreshNotesForYou() async {
    setState(() {
      notesForYou = apiService.getNotes();
    });
  }

  Future<void> _refreshNotesFollowing() async {
    setState(() {
      notesFollowing = apiService.getFollowingNotes();
    });
  }

  void _scrollToTop(ScrollController controller) {
    controller.animateTo(
      0,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              
              toolbarHeight: MediaQuery.of(context).size.height * 0.09,
              backgroundColor: kGreyColor,
              title: GestureDetector(
                onTap: () {
                  final currentIndex = DefaultTabController.of(context)!.index;
                  if (currentIndex == 0) {
                    _scrollToTop(_scrollControllerForYou);
                  } else {
                    _scrollToTop(_scrollControllerFollowing);
                  }
                },
                child: Text('Vichaar'),
              ),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Icon(FluentIcons.alert_12_regular, color: Colors.grey,),
                  onPressed: () {
                    // Handle notifications button press
                  },
                ),
                IconButton(
                  icon: Icon(FluentIcons.chat_12_regular, color: Colors.grey,),
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => ConversationsScreen(userId: userID,),
                      ),
                    );
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(35.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerHeight: 0,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: GoogleFonts.comfortaa(fontSize: 16),
                    enableFeedback: true,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.transparent, width: 0),
                      ),
                    ),
                    tabs: [
                      Tab(text: "For You", height: 50),
                      Tab(text: "Following"),
                    ],
                  ),
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(gradient: kBgGradient),
              child: TabBarView(
                children: [
                  buildNotesList(notesForYou, _refreshNotesForYou, _scrollControllerForYou),
                  buildNotesList(notesFollowing, _refreshNotesFollowing, _scrollControllerFollowing),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNotesList(Future<List<Note>> notesFuture, Future<void> Function() onRefresh, ScrollController scrollController) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: kPurpleColor,
      child: FutureBuilder<List<Note>>(
        future: notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmer();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              controller: scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NoteTile(
                    name: snapshot.data![index].name,
                    title: snapshot.data![index].title,
                    userID: snapshot.data![index].userId,
                    userName: snapshot.data![index].userName,
                    loggedID: userID,
                    time: snapshot.data![index].formatTime(),
                    noteId: snapshot.data![index].noteId,
                    likes: snapshot.data![index].likes,
                    comments: snapshot.data![index].comments,
                    image: snapshot.data![index].image,
                    postImage: snapshot.data![index].postImage ?? '',
                    index: index,
                  ),
                );
              },
              addAutomaticKeepAlives: true,
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ShimmerTile();
      },
    );
  }
}
