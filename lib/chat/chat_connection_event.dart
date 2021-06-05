part of 'chat_connection_bloc.dart';

@immutable
abstract class ChatConnectionEvent {}

class SendMessage extends ChatConnectionEvent{
  final String message;

  SendMessage(this.message);

}

class NewMessageReceived extends ChatConnectionEvent {
  final ChatMessage message;

  NewMessageReceived(this.message);
}

class Disconnected extends ChatConnectionEvent {}

