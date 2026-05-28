import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String? currentUserId;

  const MessageBubble({
    required this.message,
    this.currentUserId,
    super.key,
  });

  bool get _isMine => message.senderId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: _isMine ? const Color(0xFF7B5EA7) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(_isMine ? 16 : 4),
            bottomRight: Radius.circular(_isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              _isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: _isMine ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.sentAt),
              style: TextStyle(
                fontSize: 11,
                color: _isMine ? Colors.white70 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
