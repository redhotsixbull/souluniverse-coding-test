import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:souluniverse_coding_test/app/me_state.dart';
import 'package:souluniverse_coding_test/pages/chats/consultation_room_page.dart';

// loadMe를 호출하지 않는 wrap (실시간 표시 검증에는 사용자 로드가 불필요).
Widget _wrap(Widget child) => ChangeNotifierProvider<MeState>(
      create: (_) => MeState(),
      child: MaterialApp(home: child),
    );

void main() {
  group('ConsultationRoomPage 실시간 메시지', () {
    // 시나리오: 채팅방에 들어가면 10초마다 상담사 메시지가 도착해 화면에 표시되어야 한다.
    const firstRealtime = '그렇군요, 조금 더 이야기해 주실 수 있을까요?';

    testWidgets('10초 후 도착한 상담사 메시지가 화면에 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(const ConsultationRoomPage(
          roomId: 'demo-room',
          counselorName: '테스트 상담사',
        )),
      );
      await tester.pump(const Duration(milliseconds: 700)); // 초기 로드

      // 아직 10초가 지나지 않아 실시간 메시지는 없어야 한다.
      expect(find.text(firstRealtime), findsNothing);

      // 10초 경과 → 실시간 메시지 1건 도착.
      await tester.pump(const Duration(seconds: 10));
      await tester.pump(const Duration(milliseconds: 400)); // 스크롤

      // 새 메시지는 목록 맨 아래에 추가되므로, 보일 때까지 스크롤한 뒤 확인.
      await tester.scrollUntilVisible(
        find.text(firstRealtime),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text(firstRealtime),
        findsOneWidget,
        reason: '10초 후 도착한 상담사 메시지가 화면에 표시되어야 한다',
      );

      // 페이지 명시적 dispose (실시간 스트림 구독 정리).
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
