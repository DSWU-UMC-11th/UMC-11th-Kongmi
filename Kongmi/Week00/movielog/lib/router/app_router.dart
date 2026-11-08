import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../main.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/movie_detail_loader.dart';
import '../screens/movie_list_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/sign_up_screen.dart';
import '../theme/app_colors.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movielog_button.dart';

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
        builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(context.read<SignUpService>()),
          child: const SignUpScreen(),
        ),
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
            builder: (context, state) => ChangeNotifierProvider<MovieHomeViewModel>(
              create: (context) => MovieHomeViewModel(
                context.read<TmdbMovieService>(),
              )..loadPopular(),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => ChangeNotifierProvider<MovieListViewModel>(
              create: (context) => MovieListViewModel(
                context.read<TmdbMovieService>(),
              )..loadInitial(),
              child: const MovieListScreen(),
            ),
            routes: [
              GoRoute(
                path: ':movieId',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['movieId'] ?? '');
                  if (id == null || id < 1) {
                    return Scaffold(
                      appBar: AppBar(),
                      body: const Center(child: Text('영화 ID가 올바르지 않습니다.')),
                    );
                  }
                  final extra = state.extra;
                  return MovieDetailLoader(
                    movieId: id,
                    initialMovie: extra is TmdbMovieDto && extra.id == id ? extra : null,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const MyPageScreen(),
            routes: [
              GoRoute(
                path: 'ratings',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = context.read<LearningMemberSession>().memberId;
                  if (id == null) return const _SignUpRequiredScreen();
                  return ChangeNotifierProvider<MyRatingsViewModel>(
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      id,
                    )..load(),
                    child: const MyRatingsScreen(),
                  );
                },
              ),
            ],
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

class _SignUpRequiredScreen extends StatelessWidget {
  const _SignUpRequiredScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내가 등록한 평점', centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '학습용 회원가입이 필요합니다.',
              style: TextStyle(color: AppColors.black),
            ),
            const SizedBox(height: 16),
            MovieLogButton(
              label: '회원가입하러 가기',
              onPressed: () => context.push('/register'),
            ),
          ],
        ),
      ),
    );
  }
}
