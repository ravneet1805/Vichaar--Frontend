import 'package:flutter/material.dart';

class TypingProvider with ChangeNotifier {
  Map<String, bool> _typingStatus = {}; // Map to store typing status

  void setTypingStatus(String userId, bool isTyping) {
    _typingStatus[userId] = isTyping;
    notifyListeners();
  }

  bool isTyping(String userId) {
    return _typingStatus.containsKey(userId) ? _typingStatus[userId]! : false;
  }
}
