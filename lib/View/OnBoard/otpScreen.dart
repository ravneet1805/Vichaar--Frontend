import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:vichaar/SnackBar/errorSnackBar.dart';
import 'package:vichaar/SnackBar/successSnackbar.dart';
import 'package:vichaar/View/OnBoard/socialLinkScreen.dart';
import 'dart:convert';
import 'dart:async';
import '../../Components/myNavBar.dart';
import '../../Services/apiServices.dart';
import '../../constant.dart';

class OtpScreen extends StatefulWidget {
  final String userName;
  final String email;
  final String password;

  OtpScreen({
    Key? key,
    required this.userName,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<String> otpDigits = ["", "", "", ""];
  List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());
  bool loading = false;
  bool resendLoading = false;
  int _resendCountdown = 30; // Countdown timer in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _resendCountdown = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  Future<void> verifyOtp(String otp, BuildContext context) async {
    setState(() {
      loading = true;
    });

    const url = '${ApiService.baseUrl}/users/signup'; // Replace with your actual API endpoint

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': widget.userName,
        'email': widget.email,
        'password': widget.password,
        'otp': otp
      }),
    );

    setState(() {
      loading = false;
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);

      SuccessSnackbar.show(context, responseData['message']);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_token', responseData['token']);
      prefs.setString('userName', responseData['user']['userName']);
      prefs.setString('email', responseData['user']['email']);
      prefs.setString('userID', responseData['user']['_id']);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LinksScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      final responseData = json.decode(response.body);

      ErrorSnackbar.show(context, responseData['message']);
    }
  }

  Future<void> resendOtp() async {
    setState(() {
      resendLoading = true;
    });

    const url = '${ApiService.baseUrl}/auth/send-otp'; // Replace with your actual API endpoint

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email}),
    );

    setState(() {
      resendLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      SuccessSnackbar.show(context, responseData['message']);
      _startResendCountdown();
    } else {
      final responseData = json.decode(response.body);
      ErrorSnackbar.show(context, responseData['message']);
    }
  }

  @override
  void dispose() {
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    _timer.cancel();
    super.dispose();
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'Enter the 4-digit OTP sent to ${widget.email}',
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white24, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: kGreyColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          focusNode: focusNodes[index],
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              otpDigits[index] = value;
                              if (index < 3) {
                                FocusScope.of(context)
                                    .requestFocus(focusNodes[index + 1]);
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                            } else if (index > 0) {
                              FocusScope.of(context)
                                  .requestFocus(focusNodes[index - 1]);
                            }
                          },
                          cursorColor: kPurpleColor,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                              color: kGreyHeadTextcolor, fontSize: 24),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      if (_resendCountdown == 0 && !resendLoading) {
                        resendOtp();
                      }
                    },
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend OTP in $_resendCountdown seconds'
                          : resendLoading
                              ? 'Resending OTP...'
                              : 'Resend OTP',
                      style: TextStyle(
                        color: _resendCountdown > 0
                            ? Colors.white24
                            : kPurpleColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 100),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      String otp = otpDigits.join();
                      if (otp.length == 4) {
                        if (!loading) {
                          verifyOtp(otp, context);
                        }
                      } else {
                        ErrorSnackbar.show(
                            context, "Please enter a valid 4-digit OTP");
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
                                'Verify OTP',
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
