import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../Components/myNavBar.dart';

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late WebViewController _controller;
  final String initialUrl = 'https://vichaar.onrender.com/auth/linkedin';
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    WebView.platform = SurfaceAndroidWebView(); // Set the WebView platform for Android
  }

  Future<void> _saveUserDataToPrefs(String token, final userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('user_token', token);
    prefs.setString('name', userData['name']);
    prefs.setString('email', userData['email']);
    prefs.setString('userID', userData['_id']);
    prefs.setString('image', userData['image']);

    print('Stored user data in SharedPreferences:');
    print('Token: ${prefs.getString('user_token')}');
    print('Name: ${prefs.getString('name')}');
    print('Email: ${prefs.getString('email')}');
    print('UserID: ${prefs.getString('userID')}');
    print('Image URL: ${prefs.getString('image')}');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      body: Stack(
        children: [

    WebView(
      initialUrl: initialUrl,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
      },
      navigationDelegate: (NavigationRequest request) {
        CircularProgressIndicator();
        if (request.url.startsWith('https://vichaar.onrender.com/auth/linkedin')) {
          debugPrint('Redirecting to callback URL: ${request.url}');
          
          _handleCallbackUrl(request.url);
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onProgress: (int progress) {
              setState(() {
                this.progress = progress / 100.0; // Update loading progress
              });
            },
            onPageStarted: (String url) {
              setState(() {
                progress = 0.0; // Reset progress when a new page starts loading
              });
            },
            onPageFinished: (String url) {
              setState(() {
                progress = 1.0; // Ensure progress is complete when page finishes loading
              });
            },
      )])
    );
  }

  void _handleCallbackUrl(String url) async {
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 201) {
        Navigator.pop(context);
     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
    MyNavbar()), (Route<dynamic> route) => false);
      print('Status Code:${response.statusCode}');
        // Successful authentication
        Map<String, dynamic> responseData = json.decode(response.body);
        String token = responseData['token'];
        Map<String, dynamic> userData = responseData['user'];

        // Handle the token and user data as needed
        print('Received token: $token');
        print('User Data: $userData');
         await _saveUserDataToPrefs(token, userData );

          

        // Example: Save token and user data in local storage or state
        // SaveTokenFunction(token);
        // SaveUserDataFunction(userData);
     // } else {
        // Handle other status codes or errors
        print('Failed to authenticate with LinkedIn: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred while authenticating: $e');
    }
  }
}
