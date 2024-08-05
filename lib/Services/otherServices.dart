

import 'package:shared_preferences/shared_preferences.dart';

class OtherServices{


 static void logOut() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('user_token');
              prefs.remove('name');
              prefs.remove('email');
              prefs.remove('userID');
              prefs.remove('image');


  }
}