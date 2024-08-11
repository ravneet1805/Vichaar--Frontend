import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Components/shimmer.dart';
import 'package:vichaar/View/conversationsScreen.dart';
import 'package:vichaar/constant.dart';


import '../Components/noteTile.dart';
import '../Provider/preFetchProvider.dart';
import 'notificationScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollControllerForYou = ScrollController();
  final ScrollController _scrollControllerFollowing = ScrollController();
  String loggedID = "";

  @override
  void initState() {
    fetchLoggedId();
    super.initState();
  }

  Future<void> fetchLoggedId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedID = prefs.getString("userID") ?? '';
    print("userId form local storage: "+ loggedID );
  }

  Future<void> _refreshNotesForYou() async {
    await Provider.of<PreFetchProvider>(context, listen: false).fetchNotes();
  }

  Future<void> _refreshNotesFollowing() async {
    await Provider.of<PreFetchProvider>(context, listen: false).fetchNotes();
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
                  icon: Icon(CupertinoIcons.bell, color: Colors.grey,),
                  onPressed: () {
                    //   Navigator.push(
                    //       context,
                    //       PageTransition(
                    //         type: PageTransitionType.topToBottom,
                    //         child: NotificationScreen()
                    //   ),
                    // );
                     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationScreen()),
    );
                  },
                ),
                IconButton(
                  icon: Icon(CupertinoIcons.chat_bubble_text, color: Colors.grey,),
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => ConversationsScreen(userId: loggedID), // You can pass the user ID here as needed
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
                  buildNotesList(_refreshNotesForYou, _scrollControllerForYou,),
                  buildFollowingNotesList(_refreshNotesFollowing, _scrollControllerFollowing),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNotesList(Future<void> Function() onRefresh, ScrollController scrollController) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: kPurpleColor,
      child: Consumer<PreFetchProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return _buildShimmer();
          } else if (noteProvider.notesForYou.isEmpty) {
            return Center(child: Text('No Posts Available'));
          } else {
            return ListView.builder(
              controller: scrollController,
              itemCount: noteProvider.notesForYou.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NoteTile(
                    name: noteProvider.notesForYou[index].name,
                    title: noteProvider.notesForYou[index].title,
                    userID: noteProvider.notesForYou[index].userId,
                    userName: noteProvider.notesForYou[index].userName,
                    loggedID: loggedID,
                    time: noteProvider.notesForYou[index].formatTime(),
                    noteId: noteProvider.notesForYou[index].noteId,
                    likes: noteProvider.notesForYou[index].likes,
                    interested: noteProvider.notesForYou[index].interested,
                    comments: noteProvider.notesForYou[index].comments,
                    image: noteProvider.notesForYou[index].image,
                    postImage: noteProvider.notesForYou[index].postImage ?? '',
                    skills: noteProvider.notesForYou[index].skills ?? [],
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

  Widget buildFollowingNotesList(Future<void> Function() onRefresh, ScrollController scrollController) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: kPurpleColor,
      child: Consumer<PreFetchProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return _buildShimmer();
          } else if (noteProvider.notesFollowing.isEmpty) {
            return Center(child: Text('No Posts Available'));
          } else {
            return ListView.builder(
              controller: scrollController,
              itemCount: noteProvider.notesFollowing.length,
              itemBuilder: (context, index) {
                print(noteProvider.notesFollowing[index].skills);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NoteTile(
                    name: noteProvider.notesFollowing[index].name,
                    title: noteProvider.notesFollowing[index].title,
                    userID: noteProvider.notesFollowing[index].userId,
                    userName: noteProvider.notesFollowing[index].userName,
                    loggedID: "userID", // Use the logged-in user ID here
                    time: noteProvider.notesFollowing[index].formatTime(),
                    noteId: noteProvider.notesFollowing[index].noteId,
                    likes: noteProvider.notesFollowing[index].likes,
                    interested: noteProvider.notesFollowing[index].interested,
                    comments: noteProvider.notesFollowing[index].comments,
                    image: noteProvider.notesFollowing[index].image,
                    postImage: noteProvider.notesFollowing[index].postImage ?? '',
                    skills: noteProvider.notesFollowing[index].skills ?? [],
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
