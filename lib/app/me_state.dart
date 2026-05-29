import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repository/user_repository.dart';

/// 현재 로그인 사용자의 프로필·쿠키 잔액·즐겨찾기 상담사 목록을 관리합니다.
/// 앱 전역에서 MultiProvider로 제공되며, 여러 화면이 구독합니다.
///
/// 저장소는 [UserRepository] "계약"에 의존하며 생성자로 주입받습니다
/// (구현 교체·테스트 fake 주입이 가능).
class MeState extends ChangeNotifier {
  MeState({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;

  User? _user;
  int _cookie = 0;
  List<String> _favoriteCounselorIds = [];

  User? get user => _user;
  int get cookie => _cookie;
  List<String> get favoriteCounselorIds => _favoriteCounselorIds;

  Future<void> loadMe() async {
    final result = await _userRepository.fetchMe();
    _user = result.user;
    _cookie = result.cookie;
    _favoriteCounselorIds = List.from(result.favoriteCounselorIds);
    notifyListeners();
  }

  Future<void> addFavoriteCounselor(String counselorId) async {
    _favoriteCounselorIds = [..._favoriteCounselorIds, counselorId];
    await _userRepository.addFavorite(counselorId);
    notifyListeners();
  }

  Future<void> removeFavoriteCounselor(String counselorId) async {
    _favoriteCounselorIds = _favoriteCounselorIds
        .where((id) => id != counselorId)
        .toList();
    await _userRepository.removeFavorite(counselorId);
    notifyListeners();
  }

  Future<void> updateNickname(String newNickname) async {
    _user = _user?.copyWith(nickname: newNickname);
    await _userRepository.updateNickname(newNickname);
    notifyListeners();
  }

  void deductCookie(int amount) {
    _cookie -= amount;
    notifyListeners();
  }
}
