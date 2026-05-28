import '../models/user.dart';

// 테스트용 Mock — 실제 API 호출 없음
class _MeResult {
  final User user;
  final int cookie;
  final List<String> favoriteCounselorIds;

  const _MeResult({
    required this.user,
    required this.cookie,
    required this.favoriteCounselorIds,
  });
}

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  Future<_MeResult> fetchMe() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return _MeResult(
      user: const User(id: 'user-demo', nickname: '테스트 사용자'),
      cookie: 350,
      favoriteCounselorIds: const ['counselor-1'],
    );
  }

  Future<void> addFavorite(String counselorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> removeFavorite(String counselorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> updateNickname(String nickname) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
