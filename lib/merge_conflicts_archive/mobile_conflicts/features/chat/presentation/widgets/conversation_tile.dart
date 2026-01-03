import 'package:flutter/material.dart';
import '../../../../../data/models/message_model.dart';

class ConversationTile extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onTap;
  const ConversationTile({super.key, required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${message.fromId} → ${message.toId}'),
      subtitle: Text(message.text),
      onTap: onTap,
    );
  }
}
