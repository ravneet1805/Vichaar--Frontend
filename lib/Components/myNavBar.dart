import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/View/profileScreen.dart';
import 'package:vichaar/View/searchScreen.dart';
import '../View/addscreen.dart';
import '../View/home.dart';

class MyNavbar extends StatefulWidget {
  const MyNavbar({super.key});

  @override
  State<MyNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<MyNavbar> {
  int selectedIndex = 0;
  
  void ChangePage(int index){
    setState(() {
      selectedIndex = index;
    });
    
  }
  final List<Widget> pages=[
    HomeScreen(),
    AddScreen(),
    SearchScreen(),
    ProfileScreen(loggedUser: true,)

  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: GNav(
            haptic: true, // haptic feedback
            tabBorderRadius: 10,
            selectedIndex: selectedIndex,
            tabActiveBorder: Border.all(color: Colors.white, width: 0.9),
            color: Colors.white54,
            activeColor: Colors.white,
            gap: 10,
            onTabChange: (index) {
                ChangePage(index);
            },
            padding: const EdgeInsets.all(10),
            tabs:  [
              GButton(
                icon: Icons.home,
                textColor: Colors.white,
              ),
              GButton(
                icon: CupertinoIcons.add,
                
                textColor: Colors.white,
              ),
              GButton(
                icon: CupertinoIcons.search,
                
                textColor: Colors.white,
              ),
              GButton(
                icon: CupertinoIcons.person_fill,
                textColor: Colors.white,
              ),
            ]),
      ),
    );
  }
}
