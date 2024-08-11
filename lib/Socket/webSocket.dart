import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;



  WebSocketService() {
    connect(); // Automatically connect when the service is created
  }

  void connect() async{


  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userID') ?? '';
  print('userID: '+userId);


    _channel = WebSocketChannel.connect(
     Uri.parse('ws://172.20.10.3:8080?userId=$userId')

    );
  }

  Stream<dynamic> get stream => _channel!.stream;

  void dispose() {
    _channel?.sink.close(status.goingAway);
  }
}
