import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_peer_websocket_chat/mdns/mdns_discovery_bloc.dart';

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
            return Text("Name: ${peer.name} IP: ${peer.address}");
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
                        onPressed: () {},
                        child: Text("Conectar por direccion")),
                    ElevatedButton(
                        onPressed: () {}, child: Text("Host a server"))
                  ],
                ),
              ),
            ),
            Expanded(child: PeerResults()),
          ],
        ),
      ),
    );
  }
}
