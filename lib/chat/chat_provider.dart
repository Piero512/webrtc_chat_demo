import 'dart:async';
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
  final Peer peer;

  ChatProvider(
      {required this.rxChain,
      required this.sendMessage,
      required this.userName,
      required this.close,
      required this.peer});

  static Future<ChatProvider> connectToPeer(String username, Peer peer) async {
    var channel = await WebSocketChannel.connect(Uri.parse(peer.address));
    var client = ChatClient(channel: channel, userName: username);
    return ChatProvider(
      peer: peer,
      rxChain: client.messages,
      sendMessage: (msg) async {
        try {
          client.sendMessage(msg);
        } catch (e) {
          print("Exception received while sending: $e");
          return false;
        }
        return true;
      },
      userName: username,
      close: () => client.close(),
    );
  }

  static Future<ChatProvider> hostServer(String userName) async {
    var httpServer = await HttpServer.bind(InternetAddress.anyIPv6, 0);
    var serverPort = httpServer.port;
    var bcast = BonsoirBroadcast(
        service: BonsoirService(
      name: "Chat de $userName",
      type: "_socketchat._tcp",
      port: serverPort,
    ));
    print("Server port: ${serverPort}");
    var server = ChatServer(httpServer, bcast);
    return ChatProvider(
      peer: Peer(userName, "0.0.0.0:${serverPort}"),
      rxChain: server.messages,
      sendMessage: (msg) {
        return server.sendMessage(msg);
      },
      userName: userName,
      close: () => server.stop(),
    );
  }
}
