import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/services.dart';
import 'package:simple_peer_websocket_chat/models/message.dart';

class ChatServer {
  StreamController<ChatMessage> _controller = StreamController();
  bool stopped = false;

  Stream<ChatMessage> get messages => _controller.stream;
  List<WebSocket> sockets = [];
  final HttpServer server;
  final BonsoirBroadcast bcast;
  ChatServer(this.server, this.bcast) {
    server.transform(WebSocketTransformer()).listen(onNewConnection);
    bcast.ready.then((_) {
      return bcast.start();
    }).catchError((err){
      print("Broadcast not supported");
    }, test: (err) => err is MissingPluginException);
  }

  void onNewConnection(WebSocket newSocket) {
    newSocket.listen((event) {
      if (event is String) {
        var msg = ChatMessage.fromJson(json.decode(event));
        sendMessage(msg);
      } else {
        print("Received unknown stuff: $event");
      }
    });
    sockets.add(newSocket);
  }

  Future<void> stop() async {
    assert(!stopped, 'Trying to dispose of this server twice!');
    await _controller.close();
    for (var socket in sockets) {
      await socket.close();
    }
    sockets = [];
    await server.close(force: true);
    await bcast.stop();
    stopped = true;
  }

  Future<bool> sendMessage(ChatMessage msg) {
    _controller.add(msg);
    return broadcast(msg);
  }

  Future<bool> broadcast(ChatMessage msg) async {
    try {
      for (var socket in sockets) {
        socket.add(json.encode(msg.toJson()));
      }
    } catch (e) {
      print("Exception received while broadcasting message: $e");
      return false;
    }
    return true;
  }
}
