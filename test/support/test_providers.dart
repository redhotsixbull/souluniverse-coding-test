import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:souluniverse_coding_test/app/me_state.dart';
import 'package:souluniverse_coding_test/repository/chats_repository.dart';
import 'package:souluniverse_coding_test/repository/mock_chats_repository.dart';
import 'package:souluniverse_coding_test/repository/mock_user_repository.dart';
import 'package:souluniverse_coding_test/repository/user_repository.dart';

/// 채팅방 위젯 테스트용 공용 래퍼.
///
/// 저장소를 인터페이스로 분리한 덕에 테스트에서 mock 구현을 손쉽게 주입할 수 있다.
/// [loadMe]를 true로 주면 사용자 정보(닉네임 등)까지 로드된 상태를 만든다.
Widget wrapWithProviders(
  Widget child, {
  bool loadMe = false,
  UserRepository? userRepository,
  ChatsRepository? chatsRepository,
}) {
  final userRepo = userRepository ?? MockUserRepository();
  return MultiProvider(
    providers: [
      Provider<ChatsRepository>(
        create: (_) => chatsRepository ?? MockChatsRepository(),
      ),
      ChangeNotifierProvider<MeState>(
        create: (_) {
          final me = MeState(userRepository: userRepo);
          if (loadMe) me.loadMe();
          return me;
        },
      ),
    ],
    child: MaterialApp(home: child),
  );
}
