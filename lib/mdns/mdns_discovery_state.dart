part of 'mdns_discovery_bloc.dart';

abstract class MDNSDiscoveryState extends Equatable {
  const MDNSDiscoveryState();

  @override
  List<Object> get props => const [];
}

class InitialZeroconfState extends MDNSDiscoveryState {}

class ServicesFound extends MDNSDiscoveryState {
  final List<Peer> discovered;

  ServicesFound(this.discovered);

  List<Object> get props => [discovered];
}

class LookingForServices extends MDNSDiscoveryState {}

class NoServicesFound extends MDNSDiscoveryState {}

class ZeroconfError extends MDNSDiscoveryState {
  final String error;

  ZeroconfError(this.error);

  @override
  List<Object> get props => [];
}

class ZeroconfNotSupported extends MDNSDiscoveryState {}
