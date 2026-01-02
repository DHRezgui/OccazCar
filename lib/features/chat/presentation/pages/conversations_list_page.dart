import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/chat_provider.dart';
import '../../../../../data/models/message_model.dart';
import '../pages/chat_page.dart';

class ConversationsListPage extends ConsumerWidget {
  const ConversationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Demo user id — replace with authenticated user id
    const currentUserId = 'user1';
    final messages = ref.watch(chatControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Conversations')),
      body: FutureBuilder<void>(
        future: ref
            .read(chatControllerProvider.notifier)
            .loadConversations(currentUserId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messages.isEmpty) {
            return const Center(child: Text('Aucune conversation'));
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              final peerId = m.fromId == currentUserId ? m.toId : m.fromId;
              return ListTile(
                title: Text('Conversation avec $peerId'),
                subtitle: Text(m.text),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ChatPage(
                              peerId: peerId,
                              currentUserId: currentUserId,
                            ),
                      ),
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
