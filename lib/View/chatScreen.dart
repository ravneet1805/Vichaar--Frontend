import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vichaar/constant.dart';

import '../Services/chatService.dart';
import 'profileScreen.dart';

class ChatScreen extends StatefulWidget {
  String otherUserId;
  String name;
  String userName;
  String image;

  ChatScreen(
      {this.otherUserId = '',
      this.name = 'chat',
      this.image = '',
      this.userName = ''});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService chatService = ChatService();
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController

  @override
  void initState() {
    super.initState();
    _initializeChatService();
  }

  Future<void> _initializeChatService() async {
    await chatService.initSharedPreferences();
    setState(() {});
    // Scroll to bottom when screen is opened
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose ScrollController
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                        loggedUser: false,
                        id: widget.otherUserId,
                        image: widget.image,
                      )));
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.image),
            ),
            title: Text(
              widget.name,
              style: TextStyle(
                  color: Colors.white, overflow: TextOverflow.ellipsis),
            ),
            subtitle: Text(
              "@" + widget.userName,
              style: TextStyle(color: Colors.white60),
            )),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String currentUserId = chatService.getUserIdFromLocal();
    String otherUserId = widget.otherUserId;

    return StreamBuilder(
      stream: chatService.getMessages(currentUserId, otherUserId),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages yet"));
        }

        var messages = snapshot.data!.docs;
        messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        // Scroll to bottom after loading messages
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView.builder(
          controller: _scrollController, // Attach ScrollController here
          reverse: false, // Display messages from top to bottom
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            bool isMe = message['senderId'] == currentUserId;
            DateTime timestamp = message['timestamp'].toDate();
            String formattedTime = DateFormat('hh:mm a').format(timestamp);

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ), // 70% of screen width
                child: IntrinsicWidth(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 8.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 14.0),
                        decoration: BoxDecoration(
                          color: isMe ? kPurpleColor : Colors.grey[800],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                            bottomLeft: isMe
                                ? Radius.circular(20.0)
                                : Radius.circular(0),
                            bottomRight: isMe
                                ? Radius.circular(0)
                                : Radius.circular(20.0),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message['message'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            formattedTime,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageController,
              style: TextStyle(color: kGreyHeadTextcolor),
              cursorColor: kPurpleColor,
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                fillColor: kGreyColor,
                filled: true,
                suffixIcon: GestureDetector(
                  onTap: () {
                    String receiverId = widget.otherUserId;
                    String message = _messageController.text;
                    if (_messageController.text.isNotEmpty) {
                      chatService.sendMessage(receiverId, message);
                      _messageController.clear();
                    }
                  },
                  child: Icon(
                    FluentIcons.arrow_circle_up_16_filled,
                    color: kPurpleColor,
                    size: 30,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
