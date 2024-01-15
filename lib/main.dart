import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vichaar/AuthPages/login.dart';
import 'package:vichaar/View/chatScreen.dart';
import 'package:vichaar/View/followListScreen.dart';
import 'package:vichaar/View/profileScreen.dart';
import 'AuthPages/signup.dart';
import 'Components/myNavBar.dart';
import 'View/addscreen.dart';
import 'View/home.dart';


void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // try {
  //   await SharedPreferences.getInstance();
  // } catch (error) {
  //   print('Error initializing SharedPreferences: $error');
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.comfortaaTextTheme(),
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.comfortaa(color: Colors.white, fontSize: 24),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
        home: LoginScreen(),

        initialRoute: '/nav',
      routes: {
        '/nav':(context) => MyNavbar(),
        '/home': (context) => HomeScreen(),
        '/signup': (context) => SignupScreen(),
        '/add': (context) => AddScreen(),
        '/search': (context) => HomeScreen(),
        '/chat': (context) => ChatScreen()
      },
    );
  }
}
