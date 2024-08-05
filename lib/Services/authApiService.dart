
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService{

//   Future<void> registerUser(String name, String email, String password, BuildContext context) async {
//     if (password != confirmPassword) {
//       showTopSnackBar(
//         Overlay.of(context),
//         CustomSnackBar.error(message: "Passwords do not match"),
//       );
//       return;
//     }

//     print(name + password + email);
//     try {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         },
//       );

//       const url = 'https://vichaar.onrender.com/users/signup'; // Replace with your actual API endpoint

//       final request = http.MultipartRequest('POST', Uri.parse(url));
//       request.headers['Content-Type'] = 'application/json';
//       request.fields.addAll({
//         'name': name,
//         'email': email,
//         'password': password,
//       });

//       var response = await request.send();

//       if (response.statusCode == 201) {
//         final responseData = json.decode(await response.stream.bytesToString());

//         // Store the user token using shared preferences
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString('user_token', responseData['token']);
//         prefs.setString('name', responseData['user']['name']);
//         prefs.setString('email', responseData['user']['email']);
//         prefs.setString('userID', responseData['user']['_id']);
//         prefs.setString('image', responseData['user']['image']);

//         Navigator.pop(context); // Close the loading dialog

//         showTopSnackBar(
//           Overlay.of(context),
//           CustomSnackBar.success(message: 'Account Created'),
//         );

//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => MyNavbar()),
//           (Route<dynamic> route) => false,
//         );

//         print(responseData);
//       } else {
//         Navigator.pop(context); // Close the loading dialog

//         final responseData = json.decode(await response.stream.bytesToString());

//         showTopSnackBar(
//           Overlay.of(context),
//           CustomSnackBar.error(message: responseData['message']),
//         );

//         print('Error: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error: $error');
//     }
//   }
// }