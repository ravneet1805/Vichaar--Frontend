import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/userModel.dart';
import '../Services/apiServices.dart';
import '../View/profileScreen.dart';
import '../constant.dart';
import 'shimmer.dart';



class InterestedSection extends StatefulWidget {
  String noteId;
  InterestedSection({super.key, required this.noteId});

  @override
  State<InterestedSection> createState() => _InterestedSectionState();

}

class _InterestedSectionState extends State<InterestedSection> {
  ApiService apiService = ApiService();
  List<User> userList = [];
  bool isLoading = true;
  String loggedID = '';

  @override
  void initState() {
    super.initState();
    fetchLoggedId();
    fetchList();
  }

  Future<void> fetchLoggedId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedID =  prefs.getString("userID") ?? "N/A";
  }


  void fetchList() async {
    try {
      // Fetch data
      userList = await apiService.getInterested(widget.noteId);
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
        title: Text("Interested"),
      ),
      body: isLoading
          ? Center(
              child: _buildShimmer(),
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
                                  loggedUser: (loggedID == user.userId)
                                      ? true
                                      : false,
                                  id: user.userId,
                                  image: user.image,
                                )));
                      },
                      child: ListTile(
                        title: Text(
                          user.name ?? '',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("@"+
                          user.userName,
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: user.image != ""
                              ? NetworkImage(user.image)
                              : null
                        ),
                      ),
                    );
                  },
                ),
    );
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