import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vichaar/View/profileScreen.dart';
import 'package:vichaar/constant.dart';

import '../Model/userModel.dart';
import '../Services/apiServices.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isLoading = false;
  final ApiService apiService = ApiService();
  Timer? _debounce;

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

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Cancel the timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreyColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        title: Text(
          'Explore People',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0, // Removes shadow
      ),
      //extendBodyBehindAppBar: true,
      body: Container(
        
        decoration: BoxDecoration(gradient: kBgGradient,color: Colors.red,),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSearchBar(),
              SizedBox(height: 16),
              _isLoading
                  ? Center(
                      child: CupertinoActivityIndicator(
                          color: kPurpleColor,
                      ),
                    )
                  : _buildSearchResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 0.9),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search Users',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchResults.clear();
              });
            },
          ),
        ),
        onChanged: (query) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            _searchUsers(query);
          });
        
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: ListView.builder(
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
      child:
           ClipOval(
              child: Image.network(
             _searchResults[index].image
            ))
          
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
      ),
    );
  }
}
