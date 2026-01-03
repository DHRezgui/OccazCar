import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/chat_provider.dart';
import '../../../../../data/models/message_model.dart';

class ChatInput extends ConsumerStatefulWidget {
  final String currentUserId;
  final String peerId;
  const ChatInput({
    super.key,
    required this.currentUserId,
    required this.peerId,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(child: TextField(controller: _ctrl)),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              final text = _ctrl.text.trim();
              if (text.isEmpty) return;
              final msg = MessageModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                fromId: widget.currentUserId,
                toId: widget.peerId,
                text: text,
                timestamp: DateTime.now(),
              );
              await ref.read(chatControllerProvider.notifier).sendMessage(msg);
              _ctrl.clear();
            },
          ),
        ],
      ),
    );
  }
}
