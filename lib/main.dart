import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/me_state.dart';

void main() {
  runApp(const SoulUniverseApp());
}

class SoulUniverseApp extends StatelessWidget {
  const SoulUniverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeState()..loadMe()),
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
