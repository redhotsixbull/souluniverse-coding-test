import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/me_state.dart';
import 'repository/chats_repository.dart';
import 'repository/mock_chats_repository.dart';
import 'repository/mock_user_repository.dart';
import 'repository/user_repository.dart';

void main() {
  runApp(const SoulUniverseApp());
}

class SoulUniverseApp extends StatelessWidget {
  const SoulUniverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 저장소 구현을 한 곳에서 주입한다 — 실제 API 구현으로 교체 시 여기만 바꾸면 된다.
        Provider<UserRepository>(create: (_) => MockUserRepository()),
        Provider<ChatsRepository>(create: (_) => MockChatsRepository()),
        ChangeNotifierProvider(
          create: (ctx) =>
              MeState(userRepository: ctx.read<UserRepository>())..loadMe(),
        ),
      ],
      child: MaterialApp.router(
        title: '소울유니버스 코딩 테스트',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B5EA7)),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
