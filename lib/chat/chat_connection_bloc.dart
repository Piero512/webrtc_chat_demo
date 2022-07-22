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
      : super(ChatConnectionState(ConnectionStatus.CONNECTED, [])) {
    on<SendMessage>(
      ((event, emit) {
        final chatMessage = ChatMessage(
            arrival: DateTime.now(), from: userName, message: event.message);
        client.sendMessage(chatMessage);
        emit(state.copyWith(messages: List.from(cachedMessages)));
      }),
    );
    on<NewMessageReceived>(
      ((event, emit) {
        cachedMessages.add(event.message);
        emit(state.copyWith(messages: List.from(cachedMessages)));
      }),
    );
    on<Disconnected>(
      ((event, emit) {
        emit(state.copyWith(status: ConnectionStatus.DISCONNECTED));
      }),
    );
    client.rxChain.listen((event) {
      this.add(NewMessageReceived(event));
    });
  }
}
