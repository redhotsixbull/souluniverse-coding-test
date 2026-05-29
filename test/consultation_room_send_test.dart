import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:souluniverse_coding_test/pages/chats/consultation_room_page.dart';
import 'support/test_providers.dart';

void main() {
  group('ConsultationRoomPage 메시지 전송', () {
    // 시나리오: 하단 입력창에 메시지를 적고 전송하면,
    // 채팅 목록에 방금 보낸 내 메시지가 표시되어야 한다.
    testWidgets('메시지를 입력하고 전송하면 채팅창에 내 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const ConsultationRoomPage(
          roomId: 'demo-room',
          counselorName: '테스트 상담사',
        )),
      );
      await tester.pump(const Duration(milliseconds: 700)); // 초기 로드 완료

      const myText = '내가 보낸 테스트 메시지';
      await tester.enterText(find.byType(TextField), myText);
      await tester.pump();

      // 전송(엔터/전송 액션) 트리거.
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // 전송 지연 + 스크롤

      // 새 메시지는 목록 맨 아래에 추가되므로, 보일 때까지 스크롤한 뒤 확인.
      await tester.scrollUntilVisible(
        find.text(myText),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text(myText),
        findsOneWidget,
        reason: '전송한 메시지가 채팅 목록에 표시되어야 한다',
      );
    });
  });
}
