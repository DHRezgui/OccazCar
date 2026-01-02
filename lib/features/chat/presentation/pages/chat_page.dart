import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/message_model.dart';
import '../../presentation/providers/chat_provider.dart';

class ChatPage extends ConsumerWidget {
  final String peerId;
  final String currentUserId;

  const ChatPage({
    super.key,
    required this.peerId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatControllerProvider);
    final convo =
        messages
            .where(
              (m) =>
                  (m.fromId == currentUserId && m.toId == peerId) ||
                  (m.fromId == peerId && m.toId == currentUserId),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Chat avec $peerId')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: convo.length,
              itemBuilder: (context, i) {
                final m = convo[i];
                final mine = m.fromId == currentUserId;
                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: mine ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          _ChatInput(currentUserId: currentUserId, peerId: peerId),
        ],
      ),
    );
  }
}

class _ChatInput extends ConsumerStatefulWidget {
  final String currentUserId;
  final String peerId;
  const _ChatInput({required this.currentUserId, required this.peerId});

  @override
  ConsumerState<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<_ChatInput> {
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
