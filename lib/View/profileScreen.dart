import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Components/searchedUserList.dart';
import 'package:vichaar/Components/userNoteList.dart';
import 'package:vichaar/Services/apiServices.dart';
import 'package:vichaar/View/followListScreen.dart';
import 'package:vichaar/constant.dart';
import '../Model/userNoteModel.dart';

class ProfileScreen extends StatefulWidget {
  bool loggedUser;
  String id;
  String image;

  ProfileScreen(
      {Key? key, required this.loggedUser, this.id = '', this.image = ''})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final ApiService apiService = ApiService();
late Future<List<UserNote>> notes;
int length = 0;

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<String> userName;
  late Future<String> userEmail;
  //late String loggedId;
  List<dynamic> followersList = [];
  List<dynamic> followingList = [];
  bool loading = false;
  bool isFollowed = false;
  String x = '';
  String image = '';
  @override
  void initState() {
    UserNoteList();
    getImage();
    notes = apiService.getUserNotes();
    userName = widget.loggedUser
        ? fetchUserData('name')
        : apiService.SearchedUserData(widget.id, 'name');
    userEmail = widget.loggedUser
        ? fetchUserData('email')
        : apiService.SearchedUserData(widget.id, 'email');
    getFollowingList();
    getFollowersList();

    print(isFollowed);
    notes.then((List<UserNote> data) {
      setState(() {
        length = data.length;
      });
    });

    super.initState();
  }

  Future<void> getFollowingList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    x = prefs.getString('userID') ?? "N/A";

    print(x);
    setState(() {
      loading = true;

      if (x == widget.id) {
        widget.loggedUser = true;
      }
    });

    try {
      followingList =
          await apiService.getFollowing(widget.loggedUser ? x : widget.id);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> getFollowersList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String x = prefs.getString('userID') ?? "N/A";
    setState(() {
      loading = true;
    });

    try {
      followersList =
          await apiService.getFollowers(widget.loggedUser ? x : widget.id);

      print(followersList.length);
    } finally {
      setState(() {
        loading = false;
        for (var i = 0; i < followersList.length; i++) {
          if (followersList[i]['_id'].contains(x)) {
            isFollowed = true;
            break;
          }
        }

        print(x);
        print(isFollowed);
      });
    }
  }

  Future<String> fetchUserData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "N/A";
  }

  void getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    image = prefs.getString('image') ?? "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            stretch: true,
            actions: [
              (widget.loggedUser)
                  ? Container()
                  : isFollowed
                      ? GestureDetector(
                          onTap: () {
                            apiService.unFollowUser(widget.id);

                            setState(() {
                              isFollowed = !isFollowed;
                              followersList.removeAt(0);
                            });
                          },
                          child: Text(
                            'Following',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            apiService.followUser(widget.id);

                            setState(() {
                              isFollowed = !isFollowed;
                              followersList.add(x);
                            });
                          },
                          child: Text(
                            'Follow',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70),
                          ),
                        ),
              SizedBox(
                width: 30,
              )
            ],
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [StretchMode.zoomBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: kBgGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 60,
                        child: widget.image != '' || widget.loggedUser
                            ? ClipOval(
                                child: Image.network(
                                widget.loggedUser ? image : widget.image,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ))
                            : FutureBuilder<String>(
                                future: userName,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    loading = true;
                                    return Container();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    loading = false;
                                    return Text(
                                      snapshot.data!
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                    );
                                  }
                                },
                              ),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<String>(
                        future: userName,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              snapshot.data!,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      ),
                      FutureBuilder<String>(
                        future: userEmail,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              snapshot.data!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FollowListScreen(
                                        followers: true,
                                        title: 'Followers',
                                        id: widget.id,
                                        loggedID: x,
                                        loggedUser: widget.loggedUser,
                                      )));
                            },
                            child: Column(
                              children: [
                                Text(
                                  followersList.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16),
                                ),
                                Text("Followers",
                                    style: TextStyle(color: Colors.white))
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FollowListScreen(
                                        followers: false,
                                        title: 'Following',
                                        id: widget.id,
                                        loggedID: x,
                                        loggedUser: widget.loggedUser,
                                      )));
                            },
                            child: Column(
                              children: [
                                Text(
                                  followingList.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16),
                                ),
                                Text("Following",
                                    style: TextStyle(color: Colors.white))
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                widget.loggedUser ? "Your Posts:" : "Posts:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          widget.loggedUser
              ? UserNoteList()
              : SearchedUserNoteList(id: widget.id)
        ],
      ),
    );
  }
}
