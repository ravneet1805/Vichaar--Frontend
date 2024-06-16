import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Components/myNavBar.dart';
import 'package:vichaar/Services/apiServices.dart';
import 'dart:convert';
import '../AuthPages/signup.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../View/home.dart';




class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool show = true;
  Future<void> loginUser(String email, String password, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    const url =
        'https://vichaar.onrender.com/users/signin'; // Replace with your actual API endpoint

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );


    if (response.statusCode == 201) {
      // Successful login, handle the response accordingly
      final responseData = json.decode(response.body);
      Navigator.pop(context);

      showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.success(message: responseData['message']),
  );

      SharedPreferences prefs = await SharedPreferences.getInstance();
    print("token is ${responseData['token']}");
    prefs.setString('user_token', responseData['token']);
    prefs.setString('name', responseData['user']['name']);
    prefs.setString('email', responseData['user']['email']);
    prefs.setString('userID', responseData['user']['_id']);
    prefs.setString('image', responseData['user']['image']);
    print(prefs.getString('userID'));

    print('this is name from storage:'+prefs.getString('name').toString());
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
    MyNavbar()), (Route<dynamic> route) => false);
      
      print(responseData);
    } else {
      // Handle errors, you can show an error message to the user
      final responseData = json.decode(response.body);
      
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.error(message: responseData['message']),
  );
      print('Error: ${response.statusCode}');
      print('Response: ${response.body}');
      
    }
  }

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                
                Text(
                  'Vichaar',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,),
                ),
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text(
                    'Enter your Email and Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: TextFormField(
                    onChanged: (value) {
                      email = value;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      fillColor: Color(0xffF8F9FA),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.alternate_email,
                        color: Colors.black,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffE4E7EB),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffE4E7EB),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: show,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    fillColor: Color.fromRGBO(248, 249, 250, 1),
                    filled: true,
                    
                    suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          show = !show;
                        });
                      },
                      child:show?  Icon( Icons.visibility_off ): Icon(Icons.visibility),),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffE4E7EB),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffE4E7EB),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.double,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 100,),
                GestureDetector(
                  onTap: () {
                    print("email:"+email+"   "+"pass:"+password);
                    loginUser(email, password, context);
                  },
                  child: Container(
                    height: 50,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => SignupScreen()));
                      },
                      child: Text(
                        'Sign Up',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
