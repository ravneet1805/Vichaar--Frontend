import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/constant.dart';
import 'package:vichaar/Services/apiServices.dart';

import '../Model/commentModel.dart';
import '../View/profileScreen.dart';
import 'commentSection.dart';
import 'readMore.dart';

class NoteTile extends StatefulWidget {
  final String title;
  final String name;
  final String time;
  final String image;
  final String noteId;
  final String userID;
  String? loggedID;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final int index;
  final bool showUserName;

  NoteTile({
    Key? key,
    required this.title,
    required this.name,
    required this.time,
    required this.noteId,
    required this.likes,
    required this.userID,
    required this.comments,
    required this.image,
    required this.index,
    this.showUserName = true,
    this.loggedID
  }) : super(key: key);

  @override
  _NoteTileState createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  ApiService apiService = ApiService();
  bool isLiked = false;
  int likesCount = 0;
  int commentcount = 0;
  
  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    
    setState(() {
      isLiked = widget.likes.contains(widget.loggedID);
    });
    
    likesCount = widget.likes.length;
    commentcount = widget.comments.length;
    

  }

  

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (widget.showUserName)
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                loggedUser: false, 
                                id: widget.userID,
                                image: widget.image,
                                )));
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: widget.image != ''
                                ? ClipOval(
                                    child: Image.network(
                                    widget.image,
                                    height: 32,
                                    width: 32,
                                    fit: BoxFit.cover,
                                  ))
                                : Text(
                                    widget.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            widget.name,
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(width: 8),
              Text(
                widget.time,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ReadMoreText(
              text: widget.title,
              maxLines: 10,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: () async {
                  final noteId = widget.noteId;
                  isLiked
                      ? await apiService.unlikeNote(noteId)
                      : await apiService.likeNote(noteId);

                  setState(() {
                    isLiked = !isLiked;
                    likesCount += isLiked ? 1 : -1;
                  });
                },
              ),
              Text(
                likesCount.toString(),
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(width: 16),
              // Button to add new comment
              IconButton(
                icon: Icon(CupertinoIcons.chat_bubble, color: Colors.grey),
                onPressed: () {
                  // Handle adding new comment
                  setState(() {
                    commentcount = widget.comments.length;
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return CommentsBottomSheet(
                          noteId: widget.noteId,
                        );
                      },
                    );
                  });
                },
              ),
              Text(
                commentcount.toString(),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Divider(thickness: 0.1)
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
