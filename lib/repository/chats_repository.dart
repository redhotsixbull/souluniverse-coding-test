import '../models/chat_message.dart';

/// 채팅 메시지 조회·전송을 다루는 저장소 "계약".
///
/// 인터페이스만 보고도 가능한 동작을 알 수 있도록 정의하며,
/// 구현(Mock/API 등)을 갈아끼우거나 테스트에서 fake를 주입할 수 있게 한다.
abstract interface class ChatsRepository {
  Future<List<ChatMessage>> fetchMessages(
    String roomId, {
    int page,
    int size,
  });

  Future<void> sendMessage(String roomId, String content);
}
