import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Components/myNavBar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:vichaar/View/OnBoard/detailsScreen.dart';
import 'dart:convert';
import '../../constant.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({Key? key}) : super(key: key);

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  Future<void> saveLinks(String linkedInLink, String gitHubLink, BuildContext context) async {
    Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DetailsScreen(linkedinLink: linkedInLink, gitHubLink: gitHubLink)),
          );
  }

  @override
  Widget build(BuildContext context) {
    String linkedInUsername = '';
    String gitHubUsername = '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          'Connect your Profiles',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Share your LinkedIn and GitHub profiles to enhance your network.',

                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("LinkedIn:",
                      style: TextStyle(
                        color: kGreyHeadTextcolor,fontSize: 14
                      ),
                      ),
                        TextFormField(
                          onChanged: (value) {
                            linkedInUsername = value;
                          },
                          style: TextStyle(color: kGreyHeadTextcolor),
                          cursorColor: kPurpleColor,
                          decoration: InputDecoration(
                            hintText: 'https://www.linkedin.com/in/username',
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                            fillColor: kGreyColor,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.link,
                              color: Colors.white24,
                              size: 18,
                            ),
                            
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("GitHub:",
                      style: TextStyle(
                        color: kGreyHeadTextcolor,fontSize: 14
                      ),
                      ),
                      TextFormField(
                        onChanged: (value) {
                          gitHubUsername = value;
                        },
                        cursorColor: kPurpleColor,
                        style: TextStyle(color: kGreyHeadTextcolor),
                        decoration: InputDecoration(
                          hintText: 'https://github.com/username',
                          filled: true,
                          hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                          fillColor: kGreyColor,
                          prefixIcon: Icon(
                            Icons.link,
                            color: Colors.white24,
                            size: 18,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      print("LinkedIn Username: " + linkedInUsername + "   " + "GitHub Username: " + gitHubUsername);
                      saveLinks(linkedInUsername, gitHubUsername, context);
                    },
                    child: Container(
                      height: 50,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        //color: kPurpleColor,
                        gradient: kPurpleGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
