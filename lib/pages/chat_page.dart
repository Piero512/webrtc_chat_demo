import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_peer_websocket_chat/chat/chat_connection_bloc.dart';
import 'package:simple_peer_websocket_chat/models/message.dart';

import '../models/peer.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final Peer peer;

  const ChatPage({
    Key? key,
    required this.userName,
    required this.peer,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connected. ${widget.peer}"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: ChatView(widget.userName),
          ),
          Flexible(
            child: ColoredBox(
              color: Colors.grey,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    onSubmitted: (String msg) {
                      context.read<ChatConnectionBloc>().add(SendMessage(msg));
                      controller.clear();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
  }) : super(key: key);
  final ChatMessage message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context)
        .textTheme
        .bodyText1!
        .copyWith(color: isCurrentUser ? Colors.white : Colors.black87);
    var tagStyle = Theme.of(context)
        .textTheme
        .subtitle2!
        .copyWith(color: isCurrentUser ? Colors.white : Colors.black87);
    return LayoutBuilder(
      builder: (ctx, cons) => Padding(
        // asymmetric padding
        padding: EdgeInsets.fromLTRB(
          isCurrentUser ? 64.0 : 16.0,
          4,
          isCurrentUser ? 16.0 : 64.0,
          4,
        ),
        child: Align(
          // align the child within the container
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: DecoratedBox(
            // chat bubble decoration
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cons.maxWidth * 0.4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCurrentUser ? "You" : message.from,
                      style: tagStyle,
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      message.message,
                      style: textStyle,
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatView extends StatelessWidget {
  final String userName;

  const ChatView(this.userName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatConnectionBloc, ChatConnectionState>(
      builder: (ctx, state) {
        if (state.messages.isEmpty) {
          return Center(
            child: Text("No messages received yet."),
          );
        }
        return ListView.builder(
          itemBuilder: (ctx, index) {
            var chatMessage = state.messages[index];
            return ChatBubble(
                message: chatMessage,
                isCurrentUser: chatMessage.from == userName);
          },
          itemCount: state.messages.length,
        );
      },
    );
  }
}
