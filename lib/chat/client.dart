import 'dart:convert';

import 'package:simple_peer_websocket_chat/models/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatClient {
  String userName;
  WebSocketChannel channel;

  Stream<ChatMessage> get messages =>
      channel.stream.map((e) => ChatMessage.fromJson(json.decode(e)));

  ChatClient({required this.channel, required this.userName});

  void sendMessage(String message) {
    channel.sink.add(
      json.encode({'from': userName, 'message': message}),
    );
  }
}
