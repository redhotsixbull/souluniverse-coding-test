import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:souluniverse_coding_test/pages/chats/consultation_room_page.dart';
import 'package:souluniverse_coding_test/widgets/message_bubble.dart';
import 'support/test_providers.dart';

void main() {
  group('ConsultationRoomPage 생명주기', () {
    // 시나리오: 채팅방에 들어가면 10초 주기 실시간 스트림이 구독된다.
    // 채팅방을 벗어나면(페이지 dispose) 그 구독/타이머가 정리되어야 한다.
    // 정리되지 않으면 테스트 종료 시 "Timer is still pending"으로 실패한다.
    testWidgets('채팅방을 벗어나면 실시간 스트림 타이머가 정리된다', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const ConsultationRoomPage(
          roomId: 'demo-room',
          counselorName: '테스트 상담사',
        )),
      );

      // 초기 메시지 로드(600ms 지연) 완료 + 실시간 스트림 1회 동작.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(seconds: 10));

      // 채팅방을 벗어난다 → 페이지가 dispose 되어야 한다.
      await tester.pumpWidget(wrapWithProviders(const SizedBox.shrink()));

      // 정리됐다면 더 이상 타이머가 동작하지 않는다.
      await tester.pump(const Duration(seconds: 30));

      // 여기까지 왔을 때 pending 타이머가 남아 있으면 프레임워크가 실패시킨다.
      expect(find.byType(ConsultationRoomPage), findsNothing);
    });
  });

  group('ConsultationRoomPage 초기 메시지 로드', () {
    // 시나리오: 채팅방에 들어가면 잠깐 로딩 후 기본 메시지 목록이 보여야 한다.
    // 로드가 끝나도 화면을 갱신하지 않으면 로딩바만 계속 돌고 리스트가 비어 있다.
    testWidgets('초기 로드가 끝나면 로딩바가 사라지고 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const ConsultationRoomPage(
          roomId: 'demo-room',
          counselorName: '테스트 상담사',
        )),
      );

      // 진입 직후에는 로딩 중 표시가 보인다.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // 초기 메시지 로드(600ms 지연) 완료까지 대기.
      await tester.pump(const Duration(milliseconds: 700));

      // 로드가 끝났으면 로딩바는 사라지고, 메시지 말풍선이 화면에 그려져야 한다.
      expect(
        find.byType(LinearProgressIndicator),
        findsNothing,
        reason: '로드 완료 후에는 로딩바가 사라져야 한다',
      );
      expect(
        find.byType(MessageBubble),
        findsWidgets,
        reason: '초기 메시지 말풍선이 화면에 표시되어야 한다',
      );

      // 페이지를 명시적으로 dispose하여 실시간 스트림 구독이 정리되게 한다.
      await tester.pumpWidget(wrapWithProviders(const SizedBox.shrink()));
    });
  });
}
