import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vichaar/Components/searchedUserList.dart';
import 'package:vichaar/Components/userNoteList.dart';
import 'package:vichaar/Services/apiServices.dart';
import 'package:vichaar/Services/otherServices.dart';
import 'package:vichaar/View/followListScreen.dart';
import 'package:vichaar/constant.dart';
import '../AuthPages/login.dart';
import '../Model/userNoteModel.dart';
import 'OnBoard/onBoardHome.dart';
import 'chatScreen.dart';
import 'updateProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  bool loggedUser;
  bool throughBottomNav;
  String id;
  String image;

  ProfileScreen(
      {Key? key,
      required this.loggedUser,
      this.id = '',
      this.image = '',
      this.throughBottomNav = false})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final ApiService apiService = ApiService();
late Future<List<UserNote>> notes;
int length = 0;

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<String> fullName;
  late Future<String> userName;
  late Future<String> bio;
  late Future<String> githubLink;
  late Future<String> linkedinLink;
  late Future<String> userEmail;
  //late String loggedId;
  List<dynamic> followersList = [];
  List<dynamic> followingList = [];
  late Future<List<String>> skills;
  bool loading = false;
  bool isFollowed = false;
  String x = '';
  String image = '';
  String name = '';
  @override
  void initState() {
    UserNoteList();
    getImage();
    notes = apiService.getUserNotes();
    fullName = widget.loggedUser
        ? fetchUserData('name')
        : apiService.SearchedUserData(widget.id, 'fullName');

    userName = widget.loggedUser
        ? fetchUserData('userName')
        : apiService.SearchedUserData(widget.id, 'userName');

    bio = widget.loggedUser
        ? fetchUserData('bio')
        : apiService.SearchedUserData(widget.id, 'bio');

    githubLink = widget.loggedUser
        ? fetchUserData('githubLink')
        : apiService.SearchedUserData(widget.id, 'githubLink');

    linkedinLink = widget.loggedUser
        ? fetchUserData('linkedinLink')
        : apiService.SearchedUserData(widget.id, 'linkedinLink');

    userEmail = widget.loggedUser
        ? fetchUserData('email')
        : apiService.SearchedUserData(widget.id, 'email');

    skills =
        widget.loggedUser ? getSkillsList() : apiService.getSkills(widget.id);
    print("Skills" + skills.toString());

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

  Future<List<String>> getSkillsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('skills') ?? [];
  }

  Future<void> getFollowingList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    x = prefs.getString('userID') ?? "N/A";
    name = prefs.getString('name') ?? 'N?A';

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

  String fullNameForChat = '';
  String userNameForChat = '';

  Future<String> fetchUserData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fullNameForChat = prefs.getString(key) ?? "";
    return prefs.getString(key) ?? "N/A";
  }

  void getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    image = prefs.getString('image') ?? "N/A";
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: mq.height * 0.45,
            floating: true,
            pinned: false,
            stretch: true,
            automaticallyImplyLeading: widget.throughBottomNav ? false : true,
            title: (widget.loggedUser)
                ? Text(
                    'Profile',
                    style: TextStyle(color: Colors.white),
                  )
                : Container(),
            actions: [
              (widget.loggedUser)
                  ? IconButton(
                      icon: Icon(CupertinoIcons.settings),
                      onPressed: () async {
                        OtherServices.logOut();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => OnboardingHomeScreen()),
                            (Route<dynamic> route) => false);

                        // Handle notifications button press
                      },
                    )
                  : Container()
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
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, top: 90.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Avatar(),
                          Container(
                              child: widget.loggedUser
                                  ? SizedBox(
                                      height: 32,
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    kGreyColor),
                                            shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: kGreyHeadTextcolor),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdateProfileScreen()),
                                            );
                                          },
                                          child: Text('Edit Profile',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                    )
                                  : Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            otherUserId: widget.id,
                                            name: fullNameForChat,
                                            image: widget.image,
                                            userName: userNameForChat,
                                          ),
                                        ),
                                      );
                                          },
                                          icon: Icon(
                                            CupertinoIcons.chat_bubble_text,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        // FaIcon(FontAwesomeIcons.commentDots, color: Colors.white70,),)

                                        // SizedBox(
                                        //   width: 8,
                                        // ),
                                        isFollowed
                                            ? SizedBox(
                                                height: 32,
                                                child: ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all(kGreyColor),
                                                      shape: WidgetStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color:
                                                                  kGreyHeadTextcolor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      apiService.unFollowUser(
                                                          widget.id);

                                                      setState(() {
                                                        isFollowed =
                                                            !isFollowed;
                                                        followersList
                                                            .removeAt(0);
                                                      });
                                                    },
                                                    child: Text('Following',
                                                        style: TextStyle(
                                                            color:
                                                                kGreyHeadTextcolor))),
                                              )
                                            : SizedBox(
                                                height: 32,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      gradient: kPurpleGradient,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        shadowColor:
                                                            WidgetStateColor
                                                                .transparent,
                                                        backgroundColor:
                                                            WidgetStateColor
                                                                .transparent,
                                                        shape: WidgetStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        apiService.followUser(
                                                            widget.id);

                                                        setState(() {
                                                          isFollowed =
                                                              !isFollowed;
                                                          followersList.add(x);
                                                        });
                                                      },
                                                      child: Text('Follow',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white))),
                                                ),
                                              )
                                      ],
                                    ))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [GetName(), GetUserName()],
                          ),
                          Container(
                            width: mq.width * 0.4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Followers(), Following()],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(alignment: Alignment.centerLeft, child: GetBio()),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Container(
                          //     width: mq.width * 0.5,
                          //     child: Row(
                          //       crossAxisAlignment: CrossAxisAlignment.start ,
                          //       children: [

                          Container(width: mq.width * 0.6, child: GetSkills()),
                          //   ],
                          // )),
                          Container(
                            width: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // FaIcon(
                                //   FontAwesomeIcons.linkedin,
                                //   color: Color(0xff0072B1),
                                // ),
                                Linkedin(),
                                Github()
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
                  color: kGreyHeadTextcolor,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          widget.loggedUser
              ? UserNoteList(name: name, image: image, userName: '')
              : SearchedUserNoteList(id: widget.id, userName: 'userName')
        ],
      ),
    );
  }

  //      ------------ W I D G E T S ----------

  Widget Avatar() {
    return CircleAvatar(
      backgroundColor: kGreyColor,
      radius: 35,
      child: widget.image != '' || widget.loggedUser
          ? ClipOval(
              child: Image.network(
              widget.loggedUser ? image : widget.image,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child; // Image is loaded successfully
                } else if (loadingProgress.cumulativeBytesLoaded ==
                    loadingProgress.expectedTotalBytes) {
                  return child; // Image is fully loaded (even if it's an error image)
                } else {
                  return Center(
                      //child: CircularProgressIndicator(),
                      );
                }
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                // Error loading the image, display a placeholder or fallback image
                return Image.asset(
                    'assets/icons/default_profile.png'); // Replace with your placeholder image
              },
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ))
          : FutureBuilder<String>(
              future: fullName,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  loading = true;
                  return Container();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  loading = false;
                  return Text(
                    snapshot.data!.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  );
                }
              },
            ),
    );
  }

  Widget GetName() {
    return FutureBuilder<String>(
      future: fullName,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          fullNameForChat = snapshot.data ?? '';
          return Text(
            snapshot.data ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        }
      },
    );
  }

  Widget GetUserName() {
    return FutureBuilder<String>(
      future: userName,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          userNameForChat = snapshot.data ?? '';
          return Text(
            snapshot.data ?? '',
            style: TextStyle(color: Colors.grey),
          );
        }
      },
    );
  }

  Widget GetBio() {
    return FutureBuilder<String>(
      future: bio,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Text(
            textAlign: TextAlign.left,
            snapshot.data ?? '',
            style: TextStyle(
              color: Color(0xfff5f5f5),
            ),
          );
        }
      },
    );
  }

  Widget GetSkills() {
    return FutureBuilder<List<String>>(
      future: skills,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          print(snapshot.data);

          return Text("Skills: ${snapshot.data?.join(', ') ?? ''}",
              overflow: TextOverflow.visible,
              style: GoogleFonts.comfortaa(color: Colors.grey, fontSize: 12));
        }
      },
    );
  }

  Widget GetEmail() {
    return FutureBuilder<String>(
      future: userEmail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
    );
  }

  Widget Linkedin() {
    return FutureBuilder<String>(
      future: linkedinLink,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return GestureDetector(
            onTap: () async {
              print("tapped");
              Uri _url = Uri.parse(snapshot.data ?? '');
              if (await launchUrl(_url)) {
              } else {
                throw 'Could not launch $_url';
              }
            },
            child: snapshot.data == ''
                ? Container()
                : FaIcon(
                    FontAwesomeIcons.linkedin,
                    color: Color(0xff0072B1),
                  ),
          );
        }
      },
    );
  }

  Widget Github() {
    return FutureBuilder<String>(
      future: githubLink,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return GestureDetector(
            onTap: () async {
              print("tapped");
              Uri _url = Uri.parse(snapshot.data ?? '');
              if (await launchUrl(_url)) {
              } else {
                throw 'Could not launch $_url';
              }
            },
            child: snapshot.data == ''
                ? Container()
                : FaIcon(
                    FontAwesomeIcons.github,
                    color: kGreyHeadTextcolor,
                  ),
          );
        }
      },
    );
  }

  Widget Followers() {
    return GestureDetector(
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
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
          Text("Followers", style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  Widget Following() {
    return GestureDetector(
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
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
          Text("Following", style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }
}
