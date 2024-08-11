import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Services/apiServices.dart';
import '../Model/notificationModel.dart';
import '../Provider/notificationProvider.dart';
import '../Socket/webSocket.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late WebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();

    _webSocketService = Provider.of<WebSocketService>(context, listen: false);

    _fetchPreviousNotifications();

    _webSocketService.stream.listen((message) {
      final notification = NotificationModel.fromJson(jsonDecode(message));
      Provider.of<NotificationProvider>(context, listen: false)
          .addNotification(notification);
    });
  }

  Future<void> _fetchPreviousNotifications() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/notifications/'),
      headers: {
        'Authorization': 'bearer $token', // Use the retrieved token
      },
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;
      if (responseBody.isNotEmpty) {
        final List<dynamic> notificationData = jsonDecode(responseBody);

        // Ensure notificationData is a list
        if (notificationData is List) {
          final List<NotificationModel> notifications = notificationData
              .map<NotificationModel>((data) => NotificationModel.fromJson(data as Map<String, dynamic>))
              .toList();
          Provider.of<NotificationProvider>(context, listen: false)
              .setNotifications(notifications);
        } else {
          print('Expected a list but got: $notificationData');
        }
      } else {
        print('No notifications found.');
      }
    } else {
      print('Failed to load notifications');
    }
  } catch (e) {
    print('Error fetching notifications: $e');
  }
}


  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.notifications.isEmpty) {
            return Center(
              child: Text(
                "No Notifications",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return ListTile(
                  title: Text(notification.title),
                  subtitle: Text(notification.message),
                );
              },
            );
          }
        },
      ),
    );
  }
}
