import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vichaar/Components/shimmer.dart';

import '../Model/userModel.dart';
import '../Services/apiServices.dart';
import '../constant.dart';
import 'chatScreen.dart';

class ConversationsScreen extends StatefulWidget {
  final String userId;

  ConversationsScreen({required this.userId});

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          _searchResults = [];
        });
      } else {
        _searchUsers(_searchController.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conversations',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:TextFormField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  cursorColor: kPurpleColor,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white24),
                    fillColor: kGreyColor,
                    filled: true,
                    suffixIcon: IconButton(
                  icon:_searchController.text.isNotEmpty?
                   Icon(Icons.clear, color: Colors.white24)
                   :Icon(Icons.search, color: Colors.white24),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  
                ),
            
          ),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var user = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kGreyColor,
                          backgroundImage: NetworkImage(user.image),
                        ),
                        title: Text(
                          user.name,
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                otherUserId: user.userId, name: user.name, image: user.image, userName: user.userName, 
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chat_rooms')
                        .where('participants', arrayContains: widget.userId)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: _buildShimmer());
                      }
                      print("getting conversation list...");
                      final chatRooms = snapshot.data!.docs;

                      print(chatRooms);


                      return ListView.builder(
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {print("getting conversation list...xxxxxxxxx");
                          var chatRoom = chatRooms[index];
                          var participants = List<String>.from(chatRoom['participants']);
                          participants.remove(widget.userId);
                          String otherUserId = participants[0];
                          print("getting conversation list...222222222");

                          return FutureBuilder(
                            future: _fetchUserData(otherUserId),
                            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                              if (!snapshot.hasData) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShimmerTile(),
                                    ShimmerTile(),
                                    ShimmerTile(),
                                    ShimmerTile(),
                                    ShimmerTile(),
                                    ShimmerTile(),
                                  ],
                                );
                              }

                              var userData = snapshot.data!;
                              String fullName = userData['fullName'];
                              String photoUrl = userData['photoUrl'];
                              String userName = userData['userName'];
                              print("getting conversation list...");

                              return StreamBuilder(
                                stream: chatRoom.reference.collection('messages')
                                    .orderBy('timestamp', descending: true)
                                    .limit(1)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return ListTile(
                                      title: Text(
                                        'Loading...',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }

                                  var lastMessage = snapshot.data!.docs.first;

                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: kGreyColor,
                                      backgroundImage: NetworkImage(photoUrl),
                                    ),
                                    title: Text(
                                      fullName,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      lastMessage['message'],
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            otherUserId: otherUserId,
                                            name: fullName,
                                            image: photoUrl,
                                            userName: userName,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) return;

    List<User> results = await apiService.searchUsers(query);
    setState(() {
      _searchResults = results;
    });
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    String fullName = await apiService.SearchedUserData(userId, 'fullName');
    String photoUrl = await apiService.SearchedUserData(userId, 'image');
    String userName = await apiService.SearchedUserData(userId, 'userName');

    return {
      'fullName': fullName,
      'photoUrl': photoUrl,
      'userName': userName
    };
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ShimmerTile();
      },
    );
  }
}
