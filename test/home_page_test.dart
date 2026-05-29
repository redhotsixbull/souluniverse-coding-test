import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:souluniverse_coding_test/app/me_state.dart';
import 'package:souluniverse_coding_test/pages/home/home_page.dart';

void main() {
  group('HomePage 닉네임 반영', () {
    // 시나리오: 닉네임을 변경하면 홈 화면의 인사말이 즉시 새 닉네임으로 갱신되어야 한다.
    testWidgets('닉네임을 변경하면 홈 인사말이 갱신된다', (tester) async {
      final me = MeState();
      await tester.pumpWidget(
        ChangeNotifierProvider<MeState>.value(
          value: me,
          child: const MaterialApp(home: HomePage()),
        ),
      );

      // 내 정보 로드(1500ms) 완료 → 기본 닉네임 인사말 표시.
      me.loadMe();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('안녕하세요, 테스트 사용자님!'), findsOneWidget);

      // 닉네임 변경.
      me.updateNickname('새로운닉네임');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // 저장(200ms) + notify

      expect(
        find.text('안녕하세요, 새로운닉네임님!'),
        findsOneWidget,
        reason: '닉네임 변경 후 홈 인사말이 새 닉네임으로 갱신되어야 한다',
      );
    });
  });
}
