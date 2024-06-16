import 'package:flutter/material.dart';
import 'package:vichaar/Services/apiServices.dart';
import 'package:vichaar/View/profileScreen.dart';

import '../constant.dart';

class FollowListScreen extends StatefulWidget {
  bool followers;
  String id;
  final String title;
  String loggedID = '';
  bool loggedUser;

  FollowListScreen(
      {required this.followers,
      required this.title,
      required this.id,
      required this.loggedID,
      this.loggedUser = false,
      
      });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  ApiService apiService = ApiService();
  List<dynamic> userList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Call fetchList in initState
    fetchList();
  }

  void fetchList() async {
    try {
      // Fetch data
      userList = widget.followers
          ? await apiService.getFollowers(
            widget.loggedUser?
            widget.loggedID
            :widget.id
            )
          : await apiService.getFollowing(
            widget.loggedUser?
            widget.loggedID
            :widget.id
            );
      print(userList);
    } catch (e) {
      // Handle error
      print('Error fetching data: $e');
    } finally {
      // Set isLoading to false to stop showing the loading indicator
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgcolor,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : userList.length == 0
              ? Center(
                  child: Text(
                    'Empty',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    final user = userList[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                  loggedUser: (widget.loggedID == widget.id)
                                      ? true
                                      : false,
                                  id: user['_id'],
                                  image: user['image'],
                                )));
                      },
                      child: ListTile(
                        title: Text(
                          user['name'],
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          user['email'],
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: user.containsKey('image')
                              ? NetworkImage(user['image'])
                              : null,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
