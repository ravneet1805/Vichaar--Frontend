import 'package:flutter/material.dart';

import '../Model/notificationModel.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  void addNotification(NotificationModel notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  void setNotifications(List<NotificationModel> notifications) {
    _notifications = notifications;
    notifyListeners();
  }
}
