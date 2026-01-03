import '../../data/repositories/message_repository.dart';
import '../../data/models/message_model.dart';

class ChatService {
  final MessageRepository _messageRepository;

  ChatService(this._messageRepository);

  Future<List<MessageModel>> getConversations(String userId) async {
    return _messageRepository.getMessagesForUser(userId);
  }

  Future<void> sendMessage(MessageModel message) async {
    await _messageRepository.sendMessage(message);
  }
}
