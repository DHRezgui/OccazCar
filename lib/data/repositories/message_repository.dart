import '../datasources/remote/api_service.dart';
import '../models/message_model.dart';

abstract class MessageRepository {
  Future<List<MessageModel>> getMessagesForUser(String userId);
  Future<void> sendMessage(MessageModel message);
}

class MessageRepositoryImpl implements MessageRepository {
  final ApiService _api;

  MessageRepositoryImpl(this._api);

  @override
  Future<List<MessageModel>> getMessagesForUser(String userId) async {
    final json = await _api.get('/messages?userId=$userId');
    final items = (json['items'] as List).cast<Map<String, dynamic>>();
    return items.map((e) => MessageModel.fromJson(e)).toList();
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    await _api.post('/messages', message.toJson());
  }
}
