import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:simple_peer_websocket_chat/models/peer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message.dart';
import 'client.dart';
import 'server.dart';

typedef SendCallback = Future<bool> Function(ChatMessage);
typedef OnCloseCallback = Future<void> Function();

class ChatProvider {
  final Stream<ChatMessage> rxChain;
  final String userName;
  final SendCallback sendMessage;
  final OnCloseCallback close;
  ChatProvider({
    required this.rxChain,
    required this.sendMessage,
    required this.userName,
    required this.close
  });

  static Future<ChatProvider> connectToPeer(String username, Peer peer) async {
    var channel = await WebSocketChannel.connect(Uri.parse(peer.address));
    var client = ChatClient(channel: channel, userName: username);
    return ChatProvider(
      rxChain: client.messages,
      sendMessage: (msg) async {
        try {
          client.sendMessage(json.encode(msg.toJson()));
        } catch (e) {
          print("Exception received while sending: $e");
          return false;
        }
        return true;
      },
      userName: username,
      close: () {
        return client.close();
      }
    );
  }

  static Future<ChatProvider> hostServer(String userName) async {
    var httpServer = await HttpServer.bind(InternetAddress.anyIPv6, 0);
    var bcast = BonsoirBroadcast(
        service: BonsoirService(
      name: "Chat de $userName",
      type: "_socketchat._tcp",
      port: httpServer.port,
    ));
    var server = ChatServer(httpServer, bcast);
    return ChatProvider(
      rxChain: server.messages,
      sendMessage: (msg) {
        return server.broadcast(msg);
      },
      userName: userName,
      close: () {
        return server.stop();
      }
    );
  }
}
