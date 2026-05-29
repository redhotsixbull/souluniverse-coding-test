import '../models/user.dart';

/// 현재 로그인 사용자의 프로필 조회 결과(도메인 모델).
class MeProfile {
  final User user;
  final int cookie;
  final List<String> favoriteCounselorIds;

  const MeProfile({
    required this.user,
    required this.cookie,
    required this.favoriteCounselorIds,
  });
}

/// 사용자 프로필·즐겨찾기·닉네임을 다루는 저장소 "계약".
///
/// 인터페이스만 보고도 이 저장소가 무엇을 할 수 있는지 알 수 있도록 정의하며,
/// 구현(Mock/API 등)을 자유롭게 갈아끼우거나 테스트에서 fake를 주입할 수 있게 한다.
abstract interface class UserRepository {
  Future<MeProfile> fetchMe();
  Future<void> addFavorite(String counselorId);
  Future<void> removeFavorite(String counselorId);
  Future<void> updateNickname(String nickname);
}
