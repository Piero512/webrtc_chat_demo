part of 'mdns_discovery_bloc.dart';

abstract class MDNSDiscoveryEvent extends Equatable {
  const MDNSDiscoveryEvent();
}

class SearchForService extends MDNSDiscoveryEvent {
  final String serviceName;
  @override
  List<Object> get props => [serviceName];

  SearchForService(this.serviceName);
}
