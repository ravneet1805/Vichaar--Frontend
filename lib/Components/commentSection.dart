import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Components/commentTile.dart';
import 'package:vichaar/Model/commentModel.dart';
import 'package:vichaar/Services/apiServices.dart';
import 'package:vichaar/constant.dart';
import 'package:vichaar/Model/userModel.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String noteId;
  final Function(int)? onCommentCountChanged;

  CommentsBottomSheet({required this.noteId, this.onCommentCountChanged});

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  TextEditingController commentController = TextEditingController();
  ApiService apiService = ApiService();
  List<Comment> displayedComments = [];
  late String name;
  late String loggedID;
  late String image;
  late String userName = '';
  ScrollController _scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
    getName();
    getLoggedUsertId();
    getUserImage();
  }

  void getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'user';
    });
  }

  void getLoggedUsertId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedID = prefs.getString('userID') ?? '';
    });
  }

  void getUserImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      image = prefs.getString('image') ?? '';
    });
  }

  void _fetchComments() async {
    try {
      List<Comment> comments = await apiService.getComments(widget.noteId);
      setState(() {
        displayedComments = comments;
      });
    } catch (error) {
      print('Error fetching comments: $error');
    }
  }

  void _addComment(String text) async {
    if (text.isNotEmpty) {
      final newComment = Comment(
        name: name,
        userName: userName,
        text: text,
        commentId: '',
        createdAt: DateTime.now(),
        userId: loggedID,
        image: image,
      );
      setState(() {
        displayedComments.add(newComment);
        widget.onCommentCountChanged?.call(displayedComments.length);
        commentController.clear();
      });
      try {
        await apiService.postComment(text, widget.noteId);
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (error) {
        print('Error posting comment: $error');
      }
    }
  }

  void handleMention(User user) {
    setState(() {
      commentController.text += '@${user.name} ';
      users.clear(); // Clear suggestions after selection
    });
  }

  void searchUsers(String query) {
    if (query.isNotEmpty && query[0] == '@') {
      String searchTerm = query.substring(1); // Remove '@' from query
      apiService.searchUsers(searchTerm).then((userList) {
        setState(() {
          users = userList;
        });
      }).catchError((error) {
        print('Error searching users: $error');
      });
    } else {
      setState(() {
        users.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: kBgGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                  'Comments',
                  style: TextStyle(color: Colors.white),
                ),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: displayedComments.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No comments yet',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          controller: _scrollController,
                                          itemCount: displayedComments.length,
                                          itemBuilder: (context, index) {
                                            Comment comment =
                                                displayedComments[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 6.0),
                                              child: CommentTile(
                                                title: comment.text,
                                                userName: comment.userName,
                                                name: comment.name,
                                                time: comment.formatTime(),
                                                noteId: comment.commentId,
                                                userID: comment.userId,
                                                image: comment.image,
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                SizedBox(height: 16),

                                TextFormField(
                                  controller: commentController,
                                  style: TextStyle(color: kGreyHeadTextcolor),
                                  cursorColor: kPurpleColor,
                                  decoration: InputDecoration(
                                    hintText: 'Add a comment',
                                    hintStyle: TextStyle(
                                        color: Colors.white24, fontSize: 14),
                                    fillColor: kGreyColor,
                                    filled: true,
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        final newComment =
                                            commentController.text;
                                        _addComment(newComment);
                                        _focusNode.requestFocus();
                                      },
                                      child: Icon(
                                        FluentIcons.arrow_circle_up_16_filled,
                                        color: kPurpleColor,
                                        size: 30,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (users.isNotEmpty)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        child: Container(
                          margin: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: users.length,
                                itemBuilder: (context, index) {
                                  User user = users[index];
                                  return ListTile(
                                    title: Text(
                                      user.name,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onTap: () {
                                      handleMention(user);
                                      _focusNode
                                          .requestFocus(); // Focus back on TextField
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
