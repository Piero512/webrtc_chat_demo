import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:simple_peer_websocket_chat/models/message.dart';

class ChatServer {
  StreamController<ChatMessage> _controller = StreamController();
  bool stopped = false;
  Stream<ChatMessage> get _messages => _controller.stream;
  List<WebSocket> sockets = [];

  ChatServer();

  void onNewConnection(WebSocket newSocket) {
    newSocket.listen((event) {
      if (event is String) {
        _controller.add(ChatMessage.fromJson(json.decode(event)));
      } else {
        print("Received unknown stuff: $event");
      }
    });
    newSocket.addStream(_messages.map((event) => json.encode(event.toJson())));
    sockets.add(newSocket);
  }

  void stop() {
    assert(stopped, 'Trying to dispose of this server twice!');
    _controller.close();
    sockets.forEach((sub) {
      sub.close();
    });
    sockets = [];
    stopped = true;
  }
}
