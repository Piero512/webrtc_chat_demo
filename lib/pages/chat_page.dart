import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_peer_websocket_chat/chat/chat_connection_bloc.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  const ChatPage({Key? key, required this.userName}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your user name is: ${widget.userName}"),
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
    required this.text,
    required this.isCurrentUser,
  }) : super(key: key);
  final String text;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: isCurrentUser ? Colors.white : Colors.black87),
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
                text: chatMessage.message,
                isCurrentUser: chatMessage.from == userName);
          },
          itemCount: state.messages.length,
        );
      },
    );
  }
}
