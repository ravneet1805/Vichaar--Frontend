import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Components/noteTile.dart';
import 'package:vichaar/Components/readMore.dart';
import 'package:vichaar/constant.dart';
import '../Components/UserNoteTile.dart';
import '../Model/noteModel.dart';
import '../Model/userNoteModel.dart';
import '../Services/apiServices.dart';
import 'shimmer.dart';

class SearchedUserNoteList extends StatefulWidget {
  String id;
  final String userName;

  SearchedUserNoteList({Key? key, required this.id, this.userName = ''}) : super(key: key);

  @override
  State<SearchedUserNoteList> createState() => _SearchedUserNoteListState();
}

class _SearchedUserNoteListState extends State<SearchedUserNoteList> {
  final ApiService apiService = ApiService();

  late Future<List<Note>> notes;

  int length = 0;

  late Future<String> userName;

  late Future<String> userEmail;

  late String userID;


  @override
  void initState() {
    super.initState();
    notes = apiService.getSpecificUserNotes(widget.id);
    notes.then((List<Note> data) {
      setState(() {
        length = data.length;
      });
    });

    fetchUserID();
  }

  Future<void> fetchUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID') ?? "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: notes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                children: [
                   ShimmerTile(),
                   ShimmerTile(),
                   ShimmerTile(),
                   ShimmerTile()

                ],
              )
            ),
          );
        } else if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'No posts yet.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var userNote = snapshot.data![index];
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NoteTile(
                        title: userNote.title,
                        name: userNote.name,
                        userName: widget.userName,
                        time: userNote.formatTime(),
                        noteId: userNote.noteId,
                        likes: userNote.likes,
                        interested: userNote.interested,
                        userID: userID,
                        comments: userNote.comments,
                        index: 0,
                        loggedID: userID,
                        tapUserName: false,
                        image: userNote.image,
                        postImage: userNote.postImage ?? '',
                        skills: userNote.skills ?? [],
                        )
                    );
              },
              childCount: length,
            ),
          );
        }
      },
    );
  }
}
