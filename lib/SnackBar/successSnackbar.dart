import 'package:flutter/material.dart';


class SuccessSnackbar {
  static void show(BuildContext context, String title){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        backgroundColor: Colors.green, // Customize the background color
        duration: Duration(seconds: 3),
        dismissDirection: DismissDirection.up, // Duration of the Snackbar
        behavior: SnackBarBehavior.floating,
         margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 100,
        right: 20,
        left: 20),//  // Floating or fixed
      ),
    );
  }
}
