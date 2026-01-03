import '../datasources/remote/chat_firestore_service.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

abstract class ChatRepository {
  Future<ConversationModel> getOrCreateConversation({
    required String participant1Id,
    required String participant2Id,
    String? annonceId,
    String? annonceTitre,
  });
  Future<List<ConversationModel>> getConversations(String userId);
  Stream<List<ConversationModel>> watchConversations(String userId);
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String text,
  });
  Future<List<MessageModel>> getMessages(String conversationId);
  Stream<List<MessageModel>> watchMessages(String conversationId);
  Future<void> markAsRead({
    required String conversationId,
    required String userId,
  });
  Future<void> deleteConversation(String conversationId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatFirestoreService _firestoreService;

  ChatRepositoryImpl({required ChatFirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String participant1Id,
    required String participant2Id,
    String? annonceId,
    String? annonceTitre,
  }) async {
    return await _firestoreService.getOrCreateConversation(
      participant1Id: participant1Id,
      participant2Id: participant2Id,
      annonceId: annonceId,
      annonceTitre: annonceTitre,
    );
  }

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    return await _firestoreService.getConversations(userId);
  }

  @override
  Stream<List<ConversationModel>> watchConversations(String userId) {
    return _firestoreService.watchConversations(userId);
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    return await _firestoreService.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
    );
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    return await _firestoreService.getMessages(conversationId);
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _firestoreService.watchMessages(conversationId);
  }

  @override
  Future<void> markAsRead({
    required String conversationId,
    required String userId,
  }) async {
    await _firestoreService.markAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _firestoreService.deleteConversation(conversationId);
  }
}
