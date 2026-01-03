import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/conversation_model.dart';
import '../providers/chat_provider.dart';
import 'chat_page.dart';

/// Page listant toutes les conversations
class ConversationsPage extends ConsumerStatefulWidget {
  const ConversationsPage({super.key});

  @override
  ConsumerState<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends ConsumerState<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    // Charger les conversations au demarrage
    Future.microtask(() {
      ref.read(conversationsProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(conversationsProvider.notifier).loadConversations();
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ConversationsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(state.error!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(conversationsProvider.notifier).loadConversations();
              },
              child: const Text('Reessayer'),
            ),
          ],
        ),
      );
    }

    if (state.conversations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(conversationsProvider.notifier).loadConversations();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          final conv = state.conversations[index];
          return _buildConversationItem(context, conv);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucune conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contactez un vendeur pour demarrer une conversation',
            style: TextStyle(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, ConversationModel conv) {
    final currentUserId =
        ref.read(conversationsProvider.notifier).currentUserId;
    final unreadCount = conv.getUnreadCount(currentUserId ?? '');
    final hasUnread = unreadCount > 0;
    final partnerId = conv.getPartnerId(currentUserId ?? '');

    // Formater la date
    String timeText = '';
    if (conv.lastMessageTime != null) {
      final now = DateTime.now();
      final diff = now.difference(conv.lastMessageTime!);
      if (diff.inMinutes < 60) {
        timeText = '${diff.inMinutes}min';
      } else if (diff.inHours < 24) {
        timeText = '${diff.inHours}h';
      } else if (diff.inDays < 7) {
        timeText = '${diff.inDays}j';
      } else {
        timeText =
            '${conv.lastMessageTime!.day}/${conv.lastMessageTime!.month}';
      }
    }

    return Dismissible(
      key: Key(conv.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Supprimer'),
                content: const Text('Supprimer cette conversation ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        ref.read(conversationsProvider.notifier).deleteConversation(conv.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withAlpha(
                  (0.1 * 255).round(),
                ),
                child: Text(
                  (conv.partnerName ?? 'V').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (hasUnread)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  conv.partnerName ?? 'Vendeur',
                  style: TextStyle(
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 12,
                  color: hasUnread ? AppColors.primary : Colors.grey[400],
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (conv.annonceTitre != null)
                Text(
                  conv.annonceTitre!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary.withAlpha((0.8 * 255).round()),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      conv.lastMessage.isEmpty
                          ? 'Nouvelle conversation'
                          : conv.lastMessage,
                      style: TextStyle(
                        color:
                            hasUnread
                                ? AppColors.textPrimary
                                : Colors.grey[500],
                        fontWeight:
                            hasUnread ? FontWeight.w500 : FontWeight.normal,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasUnread)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ChatPage(
                      conversationId: conv.id,
                      peerId: partnerId,
                      currentUserId: currentUserId ?? '',
                      peerName: conv.partnerName ?? 'Vendeur',
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}
