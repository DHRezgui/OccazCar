import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../data/models/message_model.dart';

class ChatController extends StateNotifier<List<MessageModel>> {
  final Ref ref;

  ChatController(this.ref) : super([]);

  Future<void> loadConversations(String userId) async {
    final svc = ref.read(chatServiceProvider);
    final list = await svc.getConversations(userId);
    state = list;
  }

  Future<void> sendMessage(MessageModel m) async {
    final svc = ref.read(chatServiceProvider);
    await svc.sendMessage(m);
    state = [...state, m];
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, List<MessageModel>>((ref) {
      return ChatController(ref);
    });
