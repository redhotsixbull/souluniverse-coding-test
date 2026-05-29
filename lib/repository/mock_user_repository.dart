import '../models/user.dart';
import 'user_repository.dart';

/// 테스트/데모용 [UserRepository] 구현 — 실제 API 호출 없이 지연만 흉내낸다.
class MockUserRepository implements UserRepository {
  @override
  Future<MeProfile> fetchMe() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return const MeProfile(
      user: User(id: 'user-demo', nickname: '테스트 사용자'),
      cookie: 350,
      favoriteCounselorIds: ['counselor-1'],
    );
  }

  @override
  Future<void> addFavorite(String counselorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> removeFavorite(String counselorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> updateNickname(String nickname) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
