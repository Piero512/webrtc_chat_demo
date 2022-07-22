import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:simple_peer_websocket_chat/models/peer.dart';

part 'mdns_discovery_event.dart';
part 'mdns_discovery_state.dart';

class MDNSDiscoveryBloc extends Bloc<MDNSDiscoveryEvent, MDNSDiscoveryState> {
  List<Peer> cache = [];
  BonsoirDiscovery? _client;
  MDNSDiscoveryBloc() : super(InitialZeroconfState()) {
    on<SearchForService>(
      ((event, emit) async {
        try {
          var client = BonsoirDiscovery(type: event.serviceName);
          _client = client;
          emit(LookingForServices());
          await client.ready;
          client.start();
          var stream = client.eventStream;
          if (stream != null) {
            try {
              await for (var event in stream.timeout(Duration(seconds: 5))) {
                if (event.type ==
                    BonsoirDiscoveryEventType.discoveryServiceResolved) {
                  var srv = event.service as ResolvedBonsoirService;
                  print("Resolved service: $srv");
                  var ip = srv.ip;
                  if (ip != null && !(ip.startsWith("169.254"))) {
                    cache.add(Peer(srv.name, "ws://$ip:${srv.port}"));
                    emit(ServicesFound(List.from(cache)));
                  } else if (ip?.startsWith("169.254") ?? false) {
                    print("Received link-local IP? : $srv");
                  } else {
                    print("Received no IP here: $srv");
                  }
                } else {
                  print("Received  event: ${event.type}");
                }
              }
            } on TimeoutException {
              client.stop();
              _client = null;
              if (cache.isEmpty) {
                emit(NoServicesFound());
              }
            }
          } else {
            emit(ZeroconfError('The stream is supposed to exist'));
          }
        } on MissingPluginException {
          emit(ZeroconfNotSupported());
        }
      }),
    );
  }

  @override
  Future<void> close() async {
    if (state != ZeroconfNotSupported()) {
      _client?.stop();
    }
    super.close();
  }
}
