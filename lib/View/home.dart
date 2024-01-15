import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/AuthPages/login.dart';
import 'package:vichaar/constant.dart';
import '../Components/noteTile.dart';
import '../Model/commentModel.dart';
import '../Model/noteModel.dart';
import '../Services/apiServices.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample data for ListView.builder
  final ApiService apiService = ApiService();

  late Future<List<Note>> notes;

  late String userID;


  @override
  void initState(){
    super.initState();
    notes = apiService.getNotes();
    fetchUserID();
  }


  Future<void> fetchUserID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID') ?? "N/A";
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGreyColor,
        title: Text('Vichaar'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('user_token');
              prefs.remove('name');
              prefs.remove('email');
              prefs.remove('userID');
              prefs.remove('image');

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false);

              print(prefs.getString('user_token'));

              // Handle notifications button press
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications button press
            },
          ),
        ],
      ),
      //extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: kBgGradient
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: FutureBuilder<List<Note>>(
                  future: notes,
                  builder: (context, snapshot) {
                    
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else  {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          print(snapshot.data![index].comments.length);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: NoteTile(
                                name: snapshot.data![index].name,
                                title: snapshot.data![index].title,
                                userID: snapshot.data![index].userId,
                                loggedID: userID,
                                time: snapshot.data![index].getTimeAgo(),
                                noteId: snapshot.data![index].noteId,
                                likes: snapshot.data![index].likes,
                                comments: snapshot.data![index].comments,
                                image: snapshot.data![index].image,
                                index: index

                                ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
