import 'package:flutter/material.dart';

import '../Model/commentModel.dart';
import '../Services/apiServices.dart';
import '../constant.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String noteId;

  CommentsBottomSheet({
    required this.noteId,
  });

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  TextEditingController commentController = TextEditingController();

  ApiService apiService = ApiService();

  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch comments in initState
    _commentsFuture = apiService.getComments(widget.noteId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: kBgGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white),
                  );
                } else {
                  List<Comment> comments = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      Comment comment = comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(top:6.0),
                        child: ListTile(
                          title: Text(snapshot.data![index].name,
                              style: TextStyle(color: Colors.white70)),
                          subtitle: Text(snapshot.data![index].text,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          SizedBox(height: 16),
          // TextField for adding new comments
          Container(
            decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white60, width: 0.9),
                    ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: commentController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      
                    ),
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.send_rounded),
                  onPressed: () async {
                    // Handle adding new comment
                    final newComment = commentController.text;
                    if (newComment.isNotEmpty) {
                      await apiService.postComment(newComment, widget.noteId);
            
                      // Fetch updated comments after posting
                      setState(() {
                        _commentsFuture = apiService.getComments(widget.noteId);
                        commentController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
