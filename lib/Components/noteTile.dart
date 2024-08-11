import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vichaar/Components/interestedSection.dart';
import 'package:vichaar/constant.dart';
import 'package:vichaar/Services/apiServices.dart';
import '../Model/commentModel.dart';
import '../View/profileScreen.dart';
import 'commentSection.dart';
import 'fullScreenImage.dart';
import 'readMore.dart';

class NoteTile extends StatefulWidget {
  final String title;
  final String name;
  final String userName;
  final String time;
  final String image;
  final String postImage;
  final String noteId;
  final String userID;
  String? loggedID;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final List<dynamic> interested;
  final List<dynamic> skills;
  final int index;
  final bool tapUserName;

  NoteTile({
    Key? key,
    required this.title,
    required this.name,
    required this.userName,
    required this.time,
    required this.noteId,
    required this.likes,
    required this.userID,
    required this.comments,
    required this.interested,
    required this.image,
    required this.index,
    required this.skills,
    this.tapUserName = true,
    this.loggedID,
    this.postImage = '',
  }) : super(key: key);

  @override
  _NoteTileState createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile>
    with AutomaticKeepAliveClientMixin {
  ApiService apiService = ApiService();
  bool isLiked = false;
  bool isInterested = false;
  int likesCount = 0;
  int interestedCount = 0;
  int commentcount = 0;

  @override
  bool get wantKeepAlive => true;

  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    print('Skills list: ${widget.skills}');


    setState(() {
      isLiked = widget.likes.contains(widget.loggedID);
      isInterested = widget.interested.contains(widget.loggedID);

    });

    likesCount = widget.likes.length;
    commentcount = widget.comments.length;
    interestedCount = widget.interested.length;
  }

  @override
  Widget build(BuildContext context) {
    
    super.build(context);
    var mq = MediaQuery.of(context).size;
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //(widget.showUserName)
              //  ?
              GestureDetector(
                onTap: () {
                  widget.tapUserName
                      ? Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: ProfileScreen(
                              loggedUser: false,
                              id: widget.userID,
                              image: widget.image,
                            ),
                          ))
                      : Container();
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              "@${widget.userName}",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11),
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
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            ],
          ),
          //SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ReadMoreText(
              text: widget.title,
              maxLines: 10,
            ),
          ),
          Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.postImage != ''
                    ? GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                FullImageScreen(imageUrl: widget.postImage),
                          ));
                        },
                        child: Hero(
                          tag: widget.postImage,
                          child: Image.network(
                            widget.postImage,
                            height: mq.height * 0.3,
                            width: double.maxFinite,
                            
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                    child: Container(
                                  color: kGreyColor,
                                  height: mq.height * 0.3,
                                  width: double.maxFinite,
                                ));
                              }
                            },
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                      'assets/icons/default_profile.png');
                            },
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container()),
                  
          ),
          SizedBox(height: 10),
          Row(
            children: [
              widget.skills.join(', ') != "[]"
              ? Container(
                 width: mq.width * 0.7,
                child: Text("Skills: ${widget.skills.join(', ')}",
                overflow: TextOverflow.visible,
                style: GoogleFonts.comfortaa(color: Colors.grey, fontSize: 12)),
              )
              : Container()
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? CupertinoIcons.flame_fill : CupertinoIcons.flame,
                  color: isLiked ? kPurpleColor : Colors.grey,
                ),
                onPressed: () async {
                  final noteId = widget.noteId;

                  setState(() {
                    if (isLiked) {
                      likesCount--;
                    } else {
                      likesCount++;
                    }
                    isLiked = !isLiked;
                  });

                  try {
                    if (isLiked) {
                      await apiService.likeNote(noteId);
                    } else {
                      await apiService.unlikeNote(noteId);
                    }
                  } catch (e) {
                    // If the API call fails, revert the changes
                    setState(() {
                      if (isLiked) {
                        likesCount--;
                      } else {
                        likesCount++;
                      }
                      isLiked = !isLiked;
                    });
                    // Optionally, show an error message to the user
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Failed to update like status. Please try again.'),
                    ));
                  }
                },
              ),
              Text(
                likesCount.toString(),
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(width: 16),
              // Button to add new comment
              IconButton(
                icon: FaIcon(CupertinoIcons.chat_bubble, color: Colors.grey),
                onPressed: () {
                  // Handle adding new comment
                  //setState(() {
                  commentcount = widget.comments.length;
                  showModalBottomSheet<void>(
                    isScrollControlled: true,
                    useSafeArea: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CommentsBottomSheet(
                          noteId: widget.noteId,
                          onCommentCountChanged: (newCount) {
                            setState(() {
                              commentcount = newCount;
                            });
                          });
                    },
                  );
                  //  });
                },
              ),
              Text(
                commentcount.toString(),
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(width: 16),
              IconButton(
                  onPressed: () async {

                    final noteId = widget.noteId;

                  setState(() {
                    if (isInterested) {
                      interestedCount--;
                    } else {
                      interestedCount++;
                    }
                    isInterested = !isInterested;
                  });

                  try {
                    if (isInterested) {
                      await apiService.markInterested(noteId);
                    } else {
                      await apiService.notInterested(noteId);
                    }
                  } catch (e) {
                    // If the API call fails, revert the changes
                    setState(() {
                       if (isInterested) {
                      interestedCount--;
                    } else {
                      interestedCount++;
                    }
                    isInterested = !isInterested;
                    });
                    // Optionally, show an error message to the user
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Failed to update interested status. Please try again.'),
                    ));
                  }
                  },
                  icon: Icon(
                    isInterested
                        ? CupertinoIcons.hand_raised_fill
                        : CupertinoIcons.group,
                    color: isInterested ? kPurpleColor : Colors.grey,
                    size: 30,
                  )),
                  GestureDetector(
                    onTap: (){

                      Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: InterestedSection(
                              noteId: widget.noteId,
                            ),
                          ));

                    },
                    child: Text(
                                    interestedCount.toString(),
                                    style: TextStyle(color: Colors.grey),
                                  ),
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
