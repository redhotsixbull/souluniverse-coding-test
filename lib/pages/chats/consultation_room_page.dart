import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/me_state.dart';
import '../../models/chat_message.dart';
import '../../repository/chats_repository.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/message_bubble.dart';
import 'chat_room_controller.dart';

/// 1:1 상담 채팅방 화면.
///
/// 상태/로직은 [ChatRoomController]가 전담하고, 화면은 stateless 셸이
/// 작은 stateful 컴포넌트(`_MessageList`, `ChatInputBar`)를 조립하는 형태다.
/// 컨트롤러 수명은 [ChangeNotifierProvider]가 관리(제거 시 자동 dispose → 구독 정리)한다.
class ConsultationRoomPage extends StatelessWidget {
  final String roomId;
  final String counselorName;

  const ConsultationRoomPage({
    required this.roomId,
    required this.counselorName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatRoomController>(
      create: (ctx) => ChatRoomController(
        repository: ctx.read<ChatsRepository>(),
        roomId: roomId,
      )
        ..loadInitial()
        ..connectRealtime(),
      child: _ChatRoomScaffold(counselorName: counselorName),
    );
  }
}

/// stateless 셸: 앱바·로딩표시·메시지 목록·입력바를 조립한다.
class _ChatRoomScaffold extends StatelessWidget {
  final String counselorName;
  const _ChatRoomScaffold({required this.counselorName});

  @override
  Widget build(BuildContext context) {
    final meState = context.watch<MeState>();
    final controller = context.watch<ChatRoomController>();
    final myId = meState.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(counselorName),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '🍪 ${meState.cookie}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (controller.isLoading) const LinearProgressIndicator(),
          Expanded(child: _MessageList(currentUserId: myId)),
          ChatInputBar(
            onSend: (text) => context
                .read<ChatRoomController>()
                .send(text, senderId: myId ?? 'user-demo'),
          ),
        ],
      ),
    );
  }
}

/// stateful 아일랜드: 스크롤 컨트롤러를 보유하고,
/// 새 메시지가 맨 아래에 추가되면 최하단으로 스크롤하며, 상단 도달 시 과거 메시지를 로드한다.
class _MessageList extends StatefulWidget {
  final String? currentUserId;
  const _MessageList({required this.currentUserId});

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final ScrollController _scrollController = ScrollController();
  String? _lastMessageId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 0) {
      context.read<ChatRoomController>().loadOlder();
    }
  }

  /// 마지막 메시지가 바뀐 경우(=맨 아래 새 메시지 추가)에만 최하단으로 스크롤한다.
  /// 과거 메시지 로드(상단 prepend)는 마지막 메시지가 그대로라 스크롤하지 않는다.
  void _maybeStickToBottom(List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    final lastId = messages.last.id;
    if (lastId == _lastMessageId) return;
    _lastMessageId = lastId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatRoomController>().messages;
    _maybeStickToBottom(messages);
    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) => MessageBubble(
        message: messages[index],
        currentUserId: widget.currentUserId,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
