import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  io.Socket? socket;
  String receiverId = 'user2'; // Replace with the actual receiver user id

  @override
  void initState() {
    super.initState();
    socket = io.io('http://localhost:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();
    socket!.onConnect((data) => print('connected'));
    socket!.emit('user_connected', 'user1');
     // Replace with the actual user id
     print(socket?.connected);

    socket!.on('private_message', (data) {
      setState(() {
        _messages.add(data['message']);
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final data = {'receiverId': receiverId, 'message': _controller.text};
      socket!.emit('private_message', data);
      setState(() {
        _messages.add(_controller.text);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket.IO Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index], style: TextStyle(color: Colors.white),),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
