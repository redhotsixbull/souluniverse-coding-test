import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:souluniverse_coding_test/app/me_state.dart';
import 'package:souluniverse_coding_test/pages/chats/consultation_room_page.dart';
import 'package:souluniverse_coding_test/widgets/message_bubble.dart';

// 내 정보(loadMe → user-demo)가 로드된 상태로 채팅방을 띄운다.
Widget _wrap(Widget child) => ChangeNotifierProvider<MeState>(
      create: (_) => MeState()..loadMe(),
      child: MaterialApp(home: child),
    );

void main() {
  group('ConsultationRoomPage 말풍선 정렬', () {
    // 시나리오: 내 메시지(user-demo)는 우측, 상담사 메시지(counselor-1)는 좌측에 정렬되어야 한다.
    testWidgets('내 메시지는 우측, 상대 메시지는 좌측에 정렬된다', (tester) async {
      await tester.pumpWidget(
        _wrap(const ConsultationRoomPage(
          roomId: 'demo-room',
          counselorName: '테스트 상담사',
        )),
      );
      // 초기 메시지 로드(600ms) + 내 정보 로드(1500ms) + 최하단 스크롤 대기
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 400));

      Alignment alignmentOf(String senderId) {
        final bubble = find.byWidgetPredicate(
          (w) => w is MessageBubble && w.message.senderId == senderId,
        );
        expect(bubble, findsWidgets,
            reason: '$senderId 메시지 말풍선이 화면에 있어야 한다');
        final align = tester.widget<Align>(
          find.descendant(of: bubble.first, matching: find.byType(Align)).first,
        );
        return align.alignment as Alignment;
      }

      expect(alignmentOf('user-demo'), Alignment.centerRight,
          reason: '내 메시지는 우측 정렬되어야 한다');
      expect(alignmentOf('counselor-1'), Alignment.centerLeft,
          reason: '상대 메시지는 좌측 정렬되어야 한다');

      // 페이지 명시적 dispose (실시간 스트림 구독 정리).
      // MeState/loadMe를 다시 만들지 않도록 빈 위젯으로 교체한다.
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
