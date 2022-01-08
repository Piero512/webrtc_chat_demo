import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:simple_peer_websocket_chat/chat/chat_provider.dart';
import 'package:simple_peer_websocket_chat/models/message.dart';

part 'chat_connection_event.dart';
part 'chat_connection_state.dart';

class ChatConnectionBloc
    extends Bloc<ChatConnectionEvent, ChatConnectionState> {
  List<ChatMessage> cachedMessages = [];
  final ChatProvider client;

  String get userName => client.userName;

  @override
  Future<void> close() async {
    await client.close();
    return super.close();
  }

  ChatConnectionBloc(this.client)
      : super(ChatConnectionState(ConnectionStatus.CONNECTED, []));

  @override
  Stream<ChatConnectionState> mapEventToState(
    ChatConnectionEvent event,
  ) async* {
    if (event is SendMessage) {
      cachedMessages.add(ChatMessage(
          arrival: DateTime.now(), from: userName, message: event.message));
      yield state.copyWith(messages: List.from(cachedMessages));
    } else if (event is NewMessageReceived) {
      yield state.copyWith(messages: cachedMessages + [event.message]);
    } else if (event is Disconnected) {
      yield state.copyWith(status: ConnectionStatus.DISCONNECTED);
    }
  }
}
