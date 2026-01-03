class MessageModel {
  final String id;
  final String fromId;
  final String toId;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'] as String,
    fromId: json['fromId'] as String,
    toId: json['toId'] as String,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromId': fromId,
    'toId': toId,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };
}
