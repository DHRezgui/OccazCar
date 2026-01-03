import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> participantIds;
  final String? annonceId;
  final String? annonceTitre;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? createdAt;
  final Map<String, int>? unreadCount;
  
  // Infos du partenaire (rempli cote client)
  final String? partnerName;
  final String? partnerAvatar;

  ConversationModel({
    required this.id,
    required this.participantIds,
    this.annonceId,
    this.annonceTitre,
    this.lastMessage = '',
    this.lastMessageTime,
    this.createdAt,
    this.unreadCount,
    this.partnerName,
    this.partnerAvatar,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return ConversationModel(
      id: json['id'] as String? ?? '',
      participantIds: List<String>.from(json['participantIds'] ?? []),
      annonceId: json['annonceId'] as String?,
      annonceTitre: json['annonceTitre'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: parseDateTime(json['lastMessageTime']),
      createdAt: parseDateTime(json['createdAt']),
      unreadCount: json['unreadCount'] != null 
          ? Map<String, int>.from(json['unreadCount'].map(
              (k, v) => MapEntry(k.toString(), (v as num).toInt())))
          : null,
      partnerName: json['partnerName'] as String?,
      partnerAvatar: json['partnerAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'participantIds': participantIds,
    'annonceId': annonceId,
    'annonceTitre': annonceTitre,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'unreadCount': unreadCount,
    'partnerName': partnerName,
    'partnerAvatar': partnerAvatar,
  };

  ConversationModel copyWith({
    String? id,
    List<String>? participantIds,
    String? annonceId,
    String? annonceTitre,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    Map<String, int>? unreadCount,
    String? partnerName,
    String? partnerAvatar,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      annonceId: annonceId ?? this.annonceId,
      annonceTitre: annonceTitre ?? this.annonceTitre,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      partnerName: partnerName ?? this.partnerName,
      partnerAvatar: partnerAvatar ?? this.partnerAvatar,
    );
  }

  // Obtenir le nombre de messages non lus pour un utilisateur
  int getUnreadCount(String userId) {
    return unreadCount?[userId] ?? 0;
  }

  // Obtenir l'ID du partenaire
  String getPartnerId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}
