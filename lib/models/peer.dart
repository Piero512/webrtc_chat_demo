import 'package:equatable/equatable.dart';

class Peer extends Equatable {
  final String name;
  final String address;

  Peer(this.name, this.address);

  @override
  List<Object?> get props => [name,address];
}