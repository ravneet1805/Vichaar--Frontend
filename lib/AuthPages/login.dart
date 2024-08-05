import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Components/myNavBar.dart';
import 'package:vichaar/Services/apiServices.dart';
import 'package:vichaar/Services/chatService.dart';
import 'package:vichaar/SnackBar/errorSnackBar.dart';
import 'package:vichaar/SnackBar/successSnackbar.dart';
import 'package:vichaar/View/OnBoard/socialLinkScreen.dart';
import 'package:vichaar/main.dart';
import 'dart:convert';
import '../constant.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool showPassword = true;
  String email = '';
  String password = '';
  bool loading = false;


  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    setState(() {
      loading = true;
    });

    const url =
        '${ApiService.baseUrl}/users/signin'; // Replace with your actual API endpoint

      String deviceToken = '';
      FirebaseMessaging messaging = FirebaseMessaging.instance;


  String? token = await messaging.getToken();
  print("FCM Token: $token");
  deviceToken = token ?? '';
  // Send the token to your server or store it in your database



    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': email,
        'password': password,
        'deviceToken': deviceToken
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
      loading = false;
    });
      final responseData = json.decode(response.body);

      SuccessSnackbar.show(context, responseData['message']);
      ChatService().updateFcmToken(responseData['user']['_id']);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        prefs.setString('user_token', responseData['token']);
        prefs.setString('name', responseData['user']['fullName'] ?? '');
        prefs.setString('userName', responseData['user']['userName'] ?? '');
        prefs.setString('bio', responseData['user']['bio'] ?? '');
        prefs.setString('githubLink', responseData['user']['githubLink'] ?? '');
        prefs.setString(
            'linkedinLink', responseData['user']['linkedinLink'] ?? '');
        List<String> skillsList =
            (responseData['user']['skills'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
        prefs.setStringList('skills', skillsList);
        prefs.setString('email', responseData['user']['email'] ?? '');
        prefs.setString('userID', responseData['user']['_id'] ?? '');
        prefs.setString('image', responseData['user']['image'] ?? '');
      } catch (err) {
        ErrorSnackbar.show(context, err.toString());
        print(err);
      }

      if(responseData['user']['image'] == null || responseData['user']['fullName'] == null || responseData['user']['bio'] == null ){
        Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LinksScreen()),
        (Route<dynamic> route) => false,
      );
      } else{

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyNavbar()),
        (Route<dynamic> route) => false,
      );
      }
    } else {
      setState(() {
      loading = false;
    });
      final responseData = json.decode(response.body);

      
      //ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ErrorSnackbar.show(context, responseData['message']);

      
       

    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vichaar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                            ),
                          ),
                          SizedBox(height: 40),
                          Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'Enter your Email and Password',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextFormField(
                        onChanged: (value) {
                          email = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email or username';
                          }
                          return null;
                        },
                        style: TextStyle(color: kGreyHeadTextcolor),
                        cursorColor: kPurpleColor,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email or username',
                          hintStyle:
                              TextStyle(color: Colors.white24, fontSize: 14),
                          fillColor: kGreyColor,
                          filled: true,
                          prefixIcon: Icon(
                            Icons.alternate_email,
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
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      onChanged: (value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      cursorColor: kPurpleColor,
                      obscureText: showPassword,
                      style: TextStyle(color: kGreyHeadTextcolor),
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        hintStyle:
                            TextStyle(color: Colors.white24, fontSize: 14),
                        fillColor: kGreyColor,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          child: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white24,
                            size: 18,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
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
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Handle forgot password action
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: kGreyHeadTextcolor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState?.validate() ?? false) {
                          loading
                              ? null
                              : loginUser(email, password, context);
                        }
                      },
                      child: Container(
                        height: 50,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          gradient: kPurpleGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: loading
                              ? CupertinoActivityIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
