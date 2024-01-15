import 'package:flutter/material.dart';
import 'package:vichaar/Components/readMore.dart';
import 'package:vichaar/constant.dart';
import '../Components/UserNoteTile.dart';
import '../Model/userNoteModel.dart';
import '../Services/apiServices.dart';

class UserNoteList extends StatefulWidget {
  // final List<UserNote> userNotes;
  // final Function(BuildContext, UserNote) onEdit;
  // final Function(BuildContext, UserNote) onDelete;

  const UserNoteList({
    Key? key,
    // required this.userNotes,
    // required this.onEdit,
    // required this.onDelete,
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
    notes = apiService.getUserNotes();
    notes.then((List<UserNote> data) {
      setState(() {
        length = data.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserNote>>(
      future: notes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
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
                'You have not posted anything yet.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var userNote = snapshot.data?[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: kGreyColor,
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
                                        // TODO: Implement edit functionality
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
                      child: Icon(Icons.more_vert),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Container(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ReadMoreText(text: userNote?.title ?? '', maxLines: 6,)
                          
                          
                          
                          // Text(
                          //   userNote?.title ?? '',
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     fontSize: 16,
                          //   ),
                          // ),
                        ),
                      ),
                    ),
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
}
