import 'package:flutter_test/flutter_test.dart';
import 'package:souluniverse_coding_test/app/me_state.dart';
import 'package:souluniverse_coding_test/models/user.dart';
import 'package:souluniverse_coding_test/repository/user_repository.dart';

// 지연 없는 fake 저장소 — UserRepository를 인터페이스로 분리한 덕에
// 테스트가 실제 구현의 지연(1500ms 등)을 기다릴 필요 없이 즉시 주입할 수 있다.
class _FakeUserRepository implements UserRepository {
  @override
  Future<MeProfile> fetchMe() async => const MeProfile(
        user: User(id: 'user-demo', nickname: '테스트 사용자'),
        cookie: 350,
        favoriteCounselorIds: ['counselor-1'],
      );

  @override
  Future<void> addFavorite(String counselorId) async {}

  @override
  Future<void> removeFavorite(String counselorId) async {}

  @override
  Future<void> updateNickname(String nickname) async {}
}

void main() {
  group('MeState 즐겨찾기', () {
    // 시나리오: 사용자가 상담사를 즐겨찾기에 추가한 뒤,
    // 그중 "하나"의 하트를 해제한다.
    // 기대: 해제한 상담사만 빠지고, 나머지 즐겨찾기는 그대로 유지된다.
    test('한 상담사를 해제하면 그 상담사만 목록에서 빠지고 나머지는 유지된다', () async {
      final me = MeState(userRepository: _FakeUserRepository());
      await me.loadMe(); // 초기 즐겨찾기: ['counselor-1']

      await me.addFavoriteCounselor('counselor-2');
      expect(
        me.favoriteCounselorIds,
        containsAll(<String>['counselor-1', 'counselor-2']),
        reason: '추가 직후에는 두 상담사가 모두 즐겨찾기에 있어야 한다',
      );

      // counselor-1 을 해제한다.
      await me.removeFavoriteCounselor('counselor-1');

      expect(
        me.favoriteCounselorIds.contains('counselor-1'),
        isFalse,
        reason: '해제한 counselor-1 은 목록에서 빠져야 한다',
      );
      expect(
        me.favoriteCounselorIds.contains('counselor-2'),
        isTrue,
        reason: '해제하지 않은 counselor-2 는 그대로 유지되어야 한다',
      );
      expect(me.favoriteCounselorIds, equals(<String>['counselor-2']));
    });
  });
}
