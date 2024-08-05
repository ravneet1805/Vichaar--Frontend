import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/messageModel.dart';

class ChatService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late SharedPreferences _prefs;


  Future<void> updateFcmToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _firebaseFirestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    }
  }

  // Call this method when user logs in or token refreshes
  void updateTokenOnLogin(String userId) async {
    await updateFcmToken(userId);
  }




  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getUserIdFromLocal() {
    _checkPrefsInitialization(); // Ensure _prefs is initialized
    return _prefs.getString('userID') ?? '';
  }

  String getEmailFromLocal() {
    _checkPrefsInitialization(); // Ensure _prefs is initialized
    return _prefs.getString('email') ?? '';
  }

  void _checkPrefsInitialization() {
    if (!_prefs.containsKey('userID') || !_prefs.containsKey('email')) {
      throw Exception('User ID or Email not found in SharedPreferences');
    }
  }

  Future<void> sendMessage(String receiverId, String message) async {
    _checkPrefsInitialization(); // Ensure _prefs is initialized

    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: getUserIdFromLocal(),
      senderEmail: getEmailFromLocal(),
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );

    List<String> participants = [getUserIdFromLocal(), receiverId];
    participants.sort();
    String chatRoomId = participants.join("_");

    try {
      // Ensure chat room document exists
      DocumentReference chatRoomDoc = _firebaseFirestore.collection('chat_rooms').doc(chatRoomId);
      await chatRoomDoc.set({
        'participants': participants,
      }, SetOptions(merge: true)); // Merge options to not overwrite existing data

      // Add message to messages subcollection
      await chatRoomDoc.collection('messages').add(newMessage.toMap());
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      // Handle error as needed
    }
  }

  Future<void> setTypingStatus(String receiverId, bool isTyping) async {
    _checkPrefsInitialization(); // Ensure _prefs is initialized

    String currentUserId = getUserIdFromLocal();
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set({
          '${currentUserId}_typing': isTyping,
        }, SetOptions(merge: true)); // Merge options to not overwrite existing data
  }

  Stream<DocumentSnapshot> getTypingStatus(String currentUserId, String otherUserId) {
    _checkPrefsInitialization(); // Ensure _prefs is initialized

    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    _checkPrefsInitialization(); // Ensure _prefs is initialized

    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
