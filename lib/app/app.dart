import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/chats/consultation_room_page.dart';
import '../pages/home/home_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/chat/:roomId',
        builder: (context, state) => ConsultationRoomPage(
          roomId: state.pathParameters['roomId']!,
          counselorName: state.uri.queryParameters['counselorName'] ?? '상담사',
        ),
      ),
    ],
  );
}
