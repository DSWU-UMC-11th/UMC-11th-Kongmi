import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/sign_up_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: _indexFromLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => const MovieListScreen(),
            routes: [
              GoRoute(
                path: ':movieId',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final movieId =
                      int.tryParse(state.pathParameters['movieId'] ?? '');
                  return MovieDetailScreen(movieId: movieId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const MyPageScreen(),
          ),
        ],
      ),
    ],
  );

  static int _indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}