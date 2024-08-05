import 'package:flutter/material.dart';
import 'package:vichaar/Services/apiServices.dart';
import '../Model/commentModel.dart';
import '../View/profileScreen.dart';
import 'readMore.dart';

class CommentTile extends StatefulWidget {
  final String title;
  final String name;
  final String userName;
  final String time;
  final String image;
  final String noteId;
  final String userID;

  CommentTile({
    Key? key,
    required this.title,
    required this.name,
    required this.time,
    required this.noteId,
    required this.userName,
    required this.userID,
   
    required this.image,
    
  }) : super(key: key);

  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  ApiService apiService = ApiService();
  bool isLiked = false;
  int likesCount = 0;
  int commentcount = 0;
  
  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();

  }

  

  @override
  Widget build(BuildContext context) {
    final textSpans = widget.title.split(' ').map<InlineSpan>((word) {
      if (word.startsWith('@')) {
        return TextSpan(
          text: '$word ',
          style: TextStyle(color: Colors.blue),
        );
      } else {
        return TextSpan(
          text: '$word ',
          style: TextStyle(color: Colors.white),
        );
      }
    }).toList();
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
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
                            backgroundColor: Colors.black87,
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "@${widget.userName}",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                  ),
                                  Text(
                                    " • ",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11),
                                  ),
                                  Text(
                                    widget.time,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
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
          Divider(thickness: 0.1)
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
  
}
