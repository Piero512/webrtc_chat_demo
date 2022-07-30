import 'dart:async';
import 'dart:convert';

import 'package:simple_peer_websocket_chat/models/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatClient {
  final String userName;
  final WebSocketChannel channel;
  final _controller = StreamController<ChatMessage>();

  Stream<ChatMessage> get messages => _controller.stream;

  ChatClient({required this.channel, required this.userName}) {
    channel.stream.listen(
      (e) {
        final msg = ChatMessage.fromJson(json.decode(e));
        _controller.add(msg);
      },
    );
  }

  void sendMessage(ChatMessage msg) {
    channel.sink.add(json.encode(msg.toJson()));
  }

  Future<void> close() async {
    await channel.sink.close(status.goingAway, 'Leaving');
  }
}
