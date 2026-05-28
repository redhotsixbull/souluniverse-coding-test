import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        roomId: json['roomId'] as String,
        senderId: json['senderId'] as String,
        content: json['content'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );

  factory ChatMessage.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      roomId: data['roomId'] as String,
      senderId: data['senderId'] as String,
      content: data['content'] as String,
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'senderId': senderId,
        'content': content,
        'sentAt': sentAt.toIso8601String(),
        'isRead': isRead,
      };
}
