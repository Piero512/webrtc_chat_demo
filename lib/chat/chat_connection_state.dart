part of 'chat_connection_bloc.dart';

enum ConnectionStatus {
  CONNECTED,DISCONNECTED, CONNECTING
}


class ChatConnectionState extends Equatable{
  final ConnectionStatus status;
  final List<ChatMessage> messages;

  ChatConnectionState(this.status, this.messages);

  @override
  List<Object> get props => [status, messages];

  ChatConnectionState copyWith({ConnectionStatus? status, List<ChatMessage>? messages}) =>
      ChatConnectionState(status ?? this.status, messages ?? this.messages);
}

