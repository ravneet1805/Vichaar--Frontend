import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vichaar/Components/noteTile.dart';
import 'package:vichaar/Components/shimmer.dart';
import 'package:vichaar/Model/noteModel.dart';
import '../Model/userModel.dart';
import '../Services/apiServices.dart';
import '../constant.dart';
import 'profileScreen.dart'; // Import your constants for colors and styles

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late Future<List<dynamic>> trendingSkills;
  late Future<List<Note>> trendingNotes;
  TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isLoading = false;
  bool isSelected = false;
  String? selectedSkill;
  Future<List<Note>>? skillNotes;

  Timer? _debounce;

  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    trendingSkills = apiService.fetchTrendingSkills();
    trendingNotes = apiService.fetchTrendingNotes();
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<User> users = await apiService.searchUsers(query);

      print(users);

      setState(() {
        _searchResults = users;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNotesForSkill(String skill) async {
    setState(() {
      skillNotes = apiService.fetchNotesForSkill(skill);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Cancel the timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Text('Explore', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                cursorColor: kPurpleColor,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white24),
                  fillColor: kGreyColor,
                  filled: true,
                  prefixIcon: Icon(Icons.search, color: Colors.white24),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
                onChanged: (query) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _searchUsers(query);
                  });
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CupertinoActivityIndicator(
                        color: Colors.white,
                      ),
                    )
                  : _searchController.text.isNotEmpty && _searchResults.isNotEmpty
                      ? _buildSearchResults()
                      : _buildOriginalContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(
                      loggedUser: false,
                      id: _searchResults[index].userId,
                      image: _searchResults[index].image,
                    )));
          },
          leading: CircleAvatar(
            backgroundColor: kGreyColor,
            radius: 35,
            child: ClipOval(child: Image.network(_searchResults[index].image)),
          ),
          title: Text(
            _searchResults[index].name,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            "@${_searchResults[index].userName}",
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildOriginalContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Skills', style: TextStyle(color: kGreyHeadTextcolor, fontSize: 18)),
            SizedBox(height: 10),
            FutureBuilder<List<dynamic>>(
              future: trendingSkills,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CupertinoActivityIndicator(
                        color: Colors.white,
                      ),);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red));
                } else {
                  return Container(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        String skill = snapshot.data![index]['skill'];
                        bool isSelected = selectedSkill == skill;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              skill,
                            ),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedSkill = selected ? skill : null;
                                if (selectedSkill != null) {
                                  _fetchNotesForSkill(selectedSkill!);
                                }
                              });
                            },
                            selectedColor: kPurpleColor,
                            backgroundColor: kGreyColor,
                            showCheckmark: false,
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color:
                                      isSelected ? kPurpleColor : Colors.white30),
                            ),
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            selectedSkill == null ? _buildTrendingNotes() : _buildSkillNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text('Trending Vichaar', style: TextStyle(color: kGreyHeadTextcolor, fontSize: 18)),
        SizedBox(height: 10),
        FutureBuilder<List<Note>>(
          future: trendingNotes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShimmerTile(),
                  ShimmerTile(),
                  ShimmerTile(),
                  ShimmerTile(),
                  ShimmerTile(),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red));
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Note note = snapshot.data![index];
                  print(note.name);
                  return NoteTile(
                    title: note.title,
                    name: note.name,
                    userName: note.userName,
                    time: note.formatTime(),
                    noteId: note.noteId,
                    likes: note.likes,
                    userID: note.userId,
                    postImage: note.postImage ?? '',
                    comments: note.comments,
                    image: note.image,
                    index: index,
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSkillNotes() {
    return FutureBuilder<List<Note>>(
      future: skillNotes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ShimmerTile(),
              ShimmerTile(),
              ShimmerTile(),
              ShimmerTile(),
              ShimmerTile(),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Note note = snapshot.data![index];
              print(note.name);
              return NoteTile(
                title: note.title,
                name: note.name,
                userName: note.userName,
                time: note.formatTime(),
                noteId: note.noteId,
                likes: note.likes,
                userID: note.userId,
                postImage: note.postImage ?? '',
                comments: note.comments,
                image: note.image,
                index: index,
              );
            },
          );
        }
      },
    );
  }
}
