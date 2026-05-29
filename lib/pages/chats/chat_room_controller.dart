import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/chat_message.dart';
import '../../repository/chats_repository.dart';

/// 채팅방의 상태(메시지 목록·로딩·페이징·실시간 구독)와 동작을 담당한다.
///
/// 모든 상태 변경은 이 컨트롤러의 메서드를 통해 일어나고 항상 [notifyListeners]를
/// 호출하므로, "변경 후 갱신(setState) 누락" 부류의 버그가 구조적으로 생기지 않는다.
class ChatRoomController extends ChangeNotifier {
  ChatRoomController({
    required ChatsRepository repository,
    required this.roomId,
  }) : _repository = repository;

  final ChatsRepository _repository;
  final String roomId;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _page = 0;
  bool _loadingOlder = false;
  StreamSubscription<ChatMessage>? _subscription;

  // 테스트용: 실제 Firestore 대신 10초마다 상담사 메시지 도착을 시뮬레이션
  static const _mockRealtimeContents = [
    '그렇군요, 조금 더 이야기해 주실 수 있을까요?',
    '많이 힘드셨겠어요.',
    '충분히 이해가 돼요. 계속 말씀해 주세요.',
  ];

  Future<void> loadInitial() async {
    _isLoading = true;
    notifyListeners();
    final msgs = await _repository.fetchMessages(roomId, page: 0);
    _messages
      ..clear()
      ..addAll(msgs);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadOlder() async {
    if (_loadingOlder) return;
    _loadingOlder = true;
    _page++;
    final older = await _repository.fetchMessages(roomId, page: _page);
    _messages.insertAll(0, older);
    _loadingOlder = false;
    notifyListeners();
  }

  void connectRealtime() {
    _subscription = Stream.periodic(
      const Duration(seconds: 10),
      (i) => ChatMessage(
        id: 'realtime-$i',
        roomId: roomId,
        senderId: 'counselor-1',
        content: _mockRealtimeContents[i % _mockRealtimeContents.length],
        sentAt: DateTime.now(),
        isRead: false,
      ),
    ).listen((msg) {
      _messages.add(msg);
      notifyListeners();
    });
  }

  /// 보낸 메시지를 즉시(낙관적으로) 목록에 추가한 뒤 저장소로 전송한다.
  Future<void> send(String text, {required String senderId}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _messages.add(ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      roomId: roomId,
      senderId: senderId,
      content: trimmed,
      sentAt: DateTime.now(),
      isRead: false,
    ));
    notifyListeners();
    await _repository.sendMessage(roomId, trimmed);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
