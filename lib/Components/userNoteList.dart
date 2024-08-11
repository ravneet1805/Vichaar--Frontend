import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vichaar/Components/noteTile.dart';
import 'package:vichaar/Components/readMore.dart';
import 'package:vichaar/Components/shimmer.dart';
import 'package:vichaar/Model/noteModel.dart';
import 'package:vichaar/Provider/preFetchProvider.dart';
import 'package:vichaar/constant.dart';
import '../Components/UserNoteTile.dart';
import '../Model/userNoteModel.dart';
import '../Services/apiServices.dart';

class UserNoteList extends StatefulWidget {

  final String userName;
  final String name;
  final String image;

  const UserNoteList({
    Key? key,
    this.userName = '',
    this.name = '',
    this.image = ''
  }) : super(key: key);

  @override
  State<UserNoteList> createState() => _UserNoteListState();
}

class _UserNoteListState extends State<UserNoteList> {
  final ApiService apiService = ApiService();

  late Future<List<UserNote>> notes;

  int length = 0;

  late Future<String> userName;

  late Future<String> userEmail;

  @override
  void initState() {
    super.initState();
    //  notes = apiService.getUserNotes();
    // notes.then((List<UserNote> data) {
    //   setState(() {
    //     length = data.length;
    //   });
    // });



  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreFetchProvider>(
      builder: (context, noteProvider, child) {
        if (noteProvider.isLoading) {
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
        } else if (noteProvider.loggedUserNotes.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text('No Posts Available'),
            ),
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var userNote = noteProvider.loggedUserNotes[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                   // tileColor: kGreyColor,
                    trailing: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              color: kGreyColor,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.edit, color: Colors.white,),
                                      title: Text('Edit', style: TextStyle(color: Colors.white),),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _showEditDialog(userNote!);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.delete, color: Colors.white,),
                                      title: Text('Delete', style: TextStyle(color: Colors.white),),
                                      onTap: () {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: kGreyColor,
                                              surfaceTintColor: kGreyColor,
                                              title: Text('Delete Confirmation', style: TextStyle(color: Colors.white),),
                                              content: Text(
                                                'Are you sure you want to delete this post?', style: TextStyle(color: Colors.white),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel',style: TextStyle(color: Colors.white70),),
                                                ),
                                                TextButton(
                                                  onPressed: () async{
                                                    Navigator.pop(context);

                                                    bool check = await  apiService.deleteNote(
                                                        userNote?.noteId ?? '',
                                                      );
                                                      print(check);
                                                      if(check == true){
                                                        setState(() {
                                                      
                                                      notes = apiService
                                                          .getUserNotes();
                                                      notes.then(
                                                        (List<UserNote> data) {
                                                            length = data.length;
                                                        },
                                                      );
                                                    });
                                                      }
                                                    
                                                  },
                                                  child: Text('Delete',style: TextStyle(color: Colors.red[900]),),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Icon(
                        
                        Icons.more_vert),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: NoteTile(
                        title: userNote!.title,
                        name: widget.name,
                        userName: widget.userName,
                        time: userNote.formatTime(),
                        noteId: userNote.noteId,
                        likes: userNote.likes,
                        interested: userNote.interested,
                        userID: userNote.userId,
                        comments: userNote.comments,
                        index: 0,
                        loggedID: userNote.userId,
                        tapUserName: false,
                        image: widget.image,
                        postImage: userNote.postImage ?? '',
                        skills: [],
                        )
                  ),
                );
              },
              childCount: length,
            ),
          );
        }
      },
    );
  }
  void _showEditDialog(UserNote userNote) {
  TextEditingController _titleController = TextEditingController();
  _titleController.text = userNote.title;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: kGreyColor,
        title: Text('Edit Post', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _titleController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'New Text',
            
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              String newTitle = _titleController.text;
              // Call your API service to update the note
              bool success = await apiService.updateNote(
                userNote.noteId,
                newTitle,
              );
              if (success) {
                // Optionally, you can show a success message
                Navigator.pop(context); 
                
                setState(() {
                  notes = apiService.getUserNotes();
                });
              } else {
                // Handle error
                // Optionally, you can show an error message
              }
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

}
