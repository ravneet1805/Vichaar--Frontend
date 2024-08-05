import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../constant.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  String email = '';

  Future<void> sendOTP(String email, BuildContext context) async {
    // Add your logic to send OTP to the email
    // For demonstration, we'll just show a snackbar
    // showTopSnackBar(
    //   context,
    //   CustomSnackBar.success(
    //     message: "OTP sent to $email",
    //   ),
    // );

    // Navigate to the Verify OTP Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerifyOTPScreen(email: email),
      ),
    );
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
                          'Forget Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Enter your email to receive an OTP.',
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
                        Text(
                          "Email:",
                          style: TextStyle(
                            color: kGreyHeadTextcolor,
                            fontSize: 14,
                          ),
                        ),
                        TextFormField(
                          onChanged: (value) {
                            email = value;
                          },
                          style: TextStyle(color: kGreyHeadTextcolor),
                          cursorColor: kPurpleColor,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                            fillColor: kGreyColor,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.email,
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
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      sendOTP(email, context);
                    },
                    child: Container(
                      height: 50,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        gradient: kPurpleGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Send OTP',
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

class VerifyOTPScreen extends StatefulWidget {
  final String email;
  const VerifyOTPScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  String otp = '';
  String newPassword = '';

  Future<void> verifyOTPAndResetPassword(String otp, String newPassword, BuildContext context) async {
    // Add your logic to verify the OTP and reset the password
    // For demonstration, we'll just show a snackbar
    // showTopSnackBar(
    //   context,
    //   CustomSnackBar.success(
    //     message: "Password reset successfully",
    //   ),
    // );

    // Navigate back to login screen or wherever appropriate
    Navigator.of(context).popUntil((route) => route.isFirst);
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
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Enter the OTP sent to your email and set a new password.',
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
                        Text(
                          "OTP:",
                          style: TextStyle(
                            color: kGreyHeadTextcolor,
                            fontSize: 14,
                          ),
                        ),
                        TextFormField(
                          onChanged: (value) {
                            otp = value;
                          },
                          style: TextStyle(color: kGreyHeadTextcolor),
                          cursorColor: kPurpleColor,
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                            fillColor: kGreyColor,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.lock,
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
                        Text(
                          "New Password:",
                          style: TextStyle(
                            color: kGreyHeadTextcolor,
                            fontSize: 14,
                          ),
                        ),
                        TextFormField(
                          onChanged: (value) {
                            newPassword = value;
                          },
                          obscureText: true,
                          style: TextStyle(color: kGreyHeadTextcolor),
                          cursorColor: kPurpleColor,
                          decoration: InputDecoration(
                            hintText: 'Enter new password',
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                            fillColor: kGreyColor,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.lock,
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
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      verifyOTPAndResetPassword(otp, newPassword, context);
                    },
                    child: Container(
                      height: 50,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        gradient: kPurpleGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Reset Password',
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
