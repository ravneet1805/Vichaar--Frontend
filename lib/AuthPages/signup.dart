import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:vichaar/Components/myNavBar.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../View/home.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool show = false;
  void EmptyField(String email, String password, BuildContext context) {
    if (email.isEmpty || password.isEmpty) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: "fill all the fields"),
      );
    }
  }

  XFile? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = pickedFile;
      print(_imageFile.toString());
    });
  }

  Future<void> registerUser(
    String name, String email, String password, XFile? photo, BuildContext context) async {
      print(name+password+email);
  try {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    const url =
        'https://vichaar.onrender.com/users/signup'; // Replace with your actual API endpoint

    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers['Content-Type'] = 'application/json';

    request.fields.addAll({
      'name': name,
      'email': email,
      'password': password,
    });

    if (photo != null) {
      var stream = new http.ByteStream(photo!.openRead());
      stream.cast();

      var length = await photo!.length();
      final imageFile = await http.MultipartFile('photo', stream, length);
      request.files.add(imageFile);
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      final responseData = json.decode(await response.stream.bytesToString());

      // Store the user token using shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_token', responseData['token']);
      prefs.setString('name', responseData['user']['name']);
      prefs.setString('email', responseData['user']['email']);
      prefs.setString('userID', responseData['user']['_id']);
      prefs.setString('image', responseData['user']['image']);

      Navigator.pop(context); // Close the loading dialog

      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(message: 'Account Created'),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyNavbar()),
        (Route<dynamic> route) => false,
      );

      print(responseData);
    } else {
      Navigator.pop(context); // Close the loading dialog

      final responseData = json.decode(await response.stream.bytesToString());

      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: responseData['message']),
      );

      print('Error: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    String name = '';
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
            
              children: [
                SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Vichaar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: Text(
                    'Signup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                // Center(
                //   child: Text(
                //     'Enter your Email and Password',
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 16,
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white, // You can set any background color
                   child:
                  _imageFile != null
                      ? GestureDetector(
                        onTap: () =>  _pickImage(),
                        child: ClipOval(
                            child: Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          ),
                      )
                      :
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Implement image upload logic here
                      _pickImage();
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    onChanged: (value) {
                      name = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Username',
                      fillColor: Color(0xffF8F9FA),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.person,
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
                SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
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
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    fillColor: Color(0xffF8F9FA),
                    filled: true,
                    suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          show = !show;
                        });
                      },
                      child: Icon(Icons.visibility_off)),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color(0xff323F4B),
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
                SizedBox(height: 60),
                GestureDetector(
                  onTap: () {
                    print("name: $name.text   email: $email.text   password: $password.text" );
                    EmptyField(email, password, context);
                    registerUser(name, email, password, _imageFile, context);
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
                        'Create Account',
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
                      "Already have an account?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                      },
                      child: Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
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
