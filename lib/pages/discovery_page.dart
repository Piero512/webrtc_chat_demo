import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_peer_websocket_chat/chat/chat_connection_bloc.dart';
import 'package:simple_peer_websocket_chat/chat/chat_provider.dart';
import 'package:simple_peer_websocket_chat/dialogs/IPDialog.dart';
import 'package:simple_peer_websocket_chat/mdns/mdns_discovery_bloc.dart';

import '../models/peer.dart';
import 'chat_page.dart';

void _openChatScreen(
  BuildContext ctx,
  ChatProvider provider,
  String userName,
) {
  Navigator.of(ctx).push(
    MaterialPageRoute(
      builder: (ctx) => BlocProvider<ChatConnectionBloc>(
        create: (ctx) => ChatConnectionBloc(provider),
        child: ChatPage(
          userName: userName,
          peer: provider.peer
        ),
      ),
    ),
  );
}

class PeerResults extends StatelessWidget {
  const PeerResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MDNSDiscoveryBloc, MDNSDiscoveryState>(
        builder: (ctx, state) {
      if (state is LookingForServices) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is ServicesFound) {
        return ListView.builder(
          itemBuilder: (ctx, index) {
            var peer = state.discovered[index];
            return ListTile(
              title: Text("Name: ${peer.name} IP: ${peer.address}"),
              onTap: () async {
                final userName = faker.internet.userName();
                final client = await ChatProvider.connectToPeer(userName, peer);
                _openChatScreen(context, client, userName);
              },
            );
          },
          itemCount: state.discovered.length,
        );
      } else if (state is NoServicesFound) {
        return LayoutBuilder(
          builder: (ctx, constraints) => RefreshIndicator(
            onRefresh: () async {
              context
                  .read<MDNSDiscoveryBloc>()
                  .add(SearchForService('_socketchat._tcp'));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Center(
                  child:
                      Text("Sorry, no services were found. Pull to refresh!"),
                ),
              ),
            ),
          ),
        );
      } else if (state is ZeroconfError) {
        return Center(
          child: Text("Zeroconf Error: ${state.error}"),
        );
      } else if (state is ZeroconfNotSupported) {
        return Center(
            child: Text(
                "Sorry, Peer discovery is not supported on this platform."));
      }
      return Center(child: Text("Unknown Error"));
    });
  }
}

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  Future<void> hostServer(BuildContext context) async {
    var userName = faker.internet.userName();
    var server = await ChatProvider.hostServer(
      userName,
    );
    _openChatScreen(context, server, userName);
  }

  Future<void> connectPeer(BuildContext context, String ip, String port) async {
    var address = Uri(
      scheme: "ws",
      port: int.tryParse(port),
      host: ip,
    );
    var userName = faker.internet.userName();
    var client = await ChatProvider.connectToPeer(
      userName,
      Peer(
        "Direct IP",
        address.toString(),
      ),
    );
    _openChatScreen(context, client, userName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MDNSDiscoveryBloc()..add(SearchForService('_socketchat._tcp')),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Simple WebSocket chat"),
        ),
        body: Column(
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => IPDialog(
                              onConnect: (ip, port) =>
                                  connectPeer(context, ip, port),
                            ),
                          );
                        },
                        child: Text("Direct Connection")),
                    ElevatedButton(
                        onPressed: !kIsWeb ? () => hostServer(context) : null,
                        child: Text("Host a server"))
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Expanded(child: PeerResults()),
          ],
        ),
      ),
    );
  }
}
