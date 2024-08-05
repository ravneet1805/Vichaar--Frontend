import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Services/chatService.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService chatService = ChatService();
  ValueNotifier<bool> isTyping = ValueNotifier<bool>(false);
  final TextEditingController _messageController = TextEditingController();

  String currentUserId = '';
  String otherUserId;
  String otherUserName;
  String otherUserAvatarUrl;

  ChatProvider({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatarUrl,
  }) {
    _initializeChatService();
  }

  Future<void> _initializeChatService() async {
    await chatService.initSharedPreferences();
    currentUserId = chatService.getUserIdFromLocal();
    notifyListeners();
  }

  Stream<QuerySnapshot> getMessages() {
    return chatService.getMessages(currentUserId, otherUserId);
  }

  Stream<DocumentSnapshot> getTypingStatus() {
    return chatService.getTypingStatus(currentUserId, otherUserId);
  }

  void sendMessage(String message) {
    chatService.sendMessage(otherUserId, message);
  }

  void setTypingStatus(bool isTyping) {
    this.isTyping.value = isTyping;
    chatService.setTypingStatus(otherUserId, isTyping);
    notifyListeners();
  }
}
