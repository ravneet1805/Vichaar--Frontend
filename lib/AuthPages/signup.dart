import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:vichaar/SnackBar/errorSnackBar.dart';
import 'package:vichaar/SnackBar/successSnackbar.dart';
import 'dart:convert';
import 'dart:async';
import '../../constant.dart';
import '../Services/apiServices.dart';
import '../View/OnBoard/otpScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool showPassword = false;
  bool showConfirmPassword = false;
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool isUsernameAvailable = false;
  bool loading = false;
  Timer? debounce;



  Future<void> checkUsernameAvailability(String username) async {
    

    const url = '${ApiService.baseUrl}/users/checkusername';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        isUsernameAvailable = responseData['available'];
      });
    } else {

      ErrorSnackbar.show(context, "Error checking username availability");
    }
  }

  

  Future<void> registerUser(
    
      String name, String email, String password, BuildContext context) async {
        try{
    
        setState(() {
          loading = true;
        });
    

      const url = '${ApiService.baseUrl}/auth/send-otp';
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Content-Type'] = 'application/json';
      request.fields.addAll({
        'email': email.toLowerCase(),
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        
        setState(() {
          loading = false;
        });

        final responseData = json.decode(await response.stream.bytesToString());

        SuccessSnackbar.show(context, responseData['message']);

        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => OtpScreen(
                    userName: name.toLowerCase(),
                    email: email.toLowerCase(),
                    password: password,
                  )),
        );
      } else {
         setState(() {
          loading = false;
        });

        final responseData = json.decode(await response.stream.bytesToString());

        ErrorSnackbar.show(context, responseData['message']);

        
      }
    } catch (error) {
      setState(() {
          loading = false;
        });
      
      ErrorSnackbar.show(context, error.toString());
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
                            'Signup',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'Create your account to get started.',
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
                          name = value;
                          print(name);
                          if (debounce?.isActive ?? false) debounce!.cancel();
                          debounce = Timer(const Duration(milliseconds: 500), () {
                            checkUsernameAvailability(name);
                          });
                        },
                        style: TextStyle(color: kGreyHeadTextcolor),
                        cursorColor: kPurpleColor,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle:
                              TextStyle(color: Colors.white24, fontSize: 14),
                          fillColor: kGreyColor,
                          filled: true,
                          prefixIcon: Icon(
                            Icons.alternate_email_rounded,
                            color: Colors.white24,
                            size: 18,
                          ),
                          suffixIcon: 
                          isUsernameAvailable && name != ''
                              ? Icon(Icons.check, color: Colors.green)
                              : null,
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
                    isUsernameAvailable || name.isEmpty
                        ? Container()
                        : Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Sounds good, but it's already taken.",
                                style: TextStyle(color: Colors.red[900], fontSize: 12),
                              )),
                        ),
                    SizedBox(height: 20),
                    TextFormField(
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      style: TextStyle(color: kGreyHeadTextcolor),
                      cursorColor: kPurpleColor,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                        fillColor: kGreyColor,
                        filled: true,
                        prefixIcon: Icon(
                          Icons.email_rounded,
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
                    SizedBox(height: 20),
                    TextFormField(
                      obscureText: !showPassword,
                      onChanged: (value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6){
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      style: TextStyle(color: kGreyHeadTextcolor),
                      cursorColor: kPurpleColor,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                        fillColor: kGreyColor,
                        filled: true,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white24,
                          size: 18,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          child: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white24,
                            size: 18,
                          ),
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
                    SizedBox(height: 20),
                    TextFormField(
                      obscureText: !showConfirmPassword,
                      onChanged: (value) {
                        confirmPassword = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value != password){
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      style: TextStyle(color: kGreyHeadTextcolor),
                      cursorColor: kPurpleColor,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                        fillColor: kGreyColor,
                        filled: true,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white24,
                          size: 18,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                          child: Icon(
                            showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white24,
                            size: 18,
                          ),
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
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                        
                             isUsernameAvailable?
                        registerUser(name, email, password, context)
                        : null;
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
                          child:

                          loading
                          ?CupertinoActivityIndicator(
                            color: Colors.white,
                          )
                
                           :Text(
                            'Create Account',
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
      ),
    );
  }
}
