import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/session/session_guard.dart';
import '../data/models/member_info.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/favorite_api_service.dart';
import '../data/services/member_api_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/movie_detail_loader.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_search_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/splash_screen.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../view_models/favorite_detail_view_model.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
import '../view_models/session_rating_store.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movielog_button.dart';

String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/register'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    AuthStatus.initializing ||
    AuthStatus.retryRequired => atStart ? null : '/start',
    AuthStatus.signedOut ||
    AuthStatus.authenticating => atPublic ? null : '/login',
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}

Widget memberScopedPage(
  BuildContext context, {
  required String title,
  required Widget Function(
    MemberInfo member,
    SessionGuard guard,
    AuthViewModel auth,
  )
  builder,
}) {
  final auth = context.watch<AuthViewModel>();
  final member = auth.member;
  final guard = context.read<SessionGuard>();

  if (member == null || guard.accountId != member.email) {
    return Scaffold(
      appBar: CommonAppBar(
        title: title,
        centerTitle: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Center(
        child: member == null && auth.memberStatus == MemberLoadStatus.error
            ? MovieLogButton(
                width: 200,
                label: '내 정보 다시 조회',
                onPressed: () => auth.loadMember(force: true),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
  return builder(member, guard, auth);
}

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/start',
      refreshListenable: authViewModel,
      redirect: (context, state) =>
          authRedirect(authViewModel.status, state.uri.path),
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, state) {
            final auth = context.watch<AuthViewModel>();
            return SplashScreen(
              message: auth.message,
              onRetry: auth.status == AuthStatus.retryRequired
                  ? auth.restoreSession
                  : null,
            );
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
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
              currentIndex: indexFromLocation(state.uri.path),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) =>
                  ChangeNotifierProvider<MovieHomeViewModel>(
                    create: (context) =>
                        MovieHomeViewModel(context.read<TmdbMovieService>())
                          ..loadPopular(),
                    child: const HomeScreen(),
                  ),
            ),
            GoRoute(
              path: '/movies',
              builder: (context, state) => MultiProvider(
                providers: [
                  ChangeNotifierProvider<MovieListViewModel>(
                    create: (context) =>
                        MovieListViewModel(context.read<TmdbMovieService>())
                          ..loadGenres(),
                  ),
                  ChangeNotifierProvider<PagedMoviesViewModel>(
                    create: (context) => PagedMoviesViewModel(
                      tmdbApi: context.read<TmdbMovieService>(),
                    )..loadInitial(),
                  ),
                ],
                child: const MovieListScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'search',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) =>
                      ChangeNotifierProvider<PagedMoviesViewModel>(
                        create: (context) => PagedMoviesViewModel(
                          tmdbApi: context.read<TmdbMovieService>(),
                        ),
                        child: MovieSearchScreen(
                          onOpenMovie: (movie) async {
                            await context.push(
                              '/movies/${movie.id}',
                              extra: movie,
                            );
                          },
                        ),
                      ),
                ),
                GoRoute(
                  path: ':movieId',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.tryParse(
                      state.pathParameters['movieId'] ?? '',
                    );
                    if (id == null || id < 1) {
                      return Scaffold(
                        appBar: AppBar(),
                        body: const Center(child: Text('영화 ID가 올바르지 않습니다.')),
                      );
                    }
                    final extra = state.extra;
                    return memberScopedPage(
                      context,
                      title: '영화 상세',
                      builder: (member, guard, auth) {
                        final authVersion = auth.sessionVersion;
                        return ChangeNotifierProvider<FavoriteDetailViewModel>(
                          key: ValueKey('${member.email}:${guard.generation}'),
                          create: (context) => FavoriteDetailViewModel(
                            movieId: id,
                            favoriteApi: context.read<FavoriteApiService>(),
                            sessionGuard: guard,
                            accountId: member.email,
                            onSessionExpired: () =>
                                auth.expireSession(ifVersion: authVersion),
                          ),
                          child: MovieDetailLoader(
                            movieId: id,
                            initialMovie:
                                extra is TmdbMovieDto && extra.id == id
                                ? extra
                                : null,
                          ),
                        );
                      },
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
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) =>
                      ChangeNotifierProvider<MyRatingsViewModel>(
                        create: (context) => MyRatingsViewModel(
                          context.read<RatingApiService>(),
                          context.read<TmdbMovieService>(),
                          context.read<SessionRatingStore>(),
                          context.read<AuthViewModel>(),
                        ),
                        child: const MyRatingsScreen(),
                      ),
                ),
                GoRoute(
                  path: 'favorites',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => memberScopedPage(
                    context,
                    title: '내 즐겨찾기',
                    builder: (member, guard, auth) {
                      final authVersion = auth.sessionVersion;
                      return ChangeNotifierProvider<FavoritesViewModel>(
                        key: ValueKey('${member.email}:${guard.generation}'),
                        create: (context) => FavoritesViewModel(
                          favoriteApi: context.read<FavoriteApiService>(),
                          tmdbApi: context.read<TmdbMovieService>(),
                          sessionGuard: guard,
                          accountId: member.email,
                          onSessionExpired: () =>
                              auth.expireSession(ifVersion: authVersion),
                        ),
                        child: FavoritesScreen(
                          onOpenMovie: (movie) async {
                            await context.push(
                              '/movies/${movie.id}',
                              extra: movie,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                GoRoute(
                  path: 'profile/edit',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final auth = context.watch<AuthViewModel>();
                    if (auth.member == null) {
                      return Scaffold(
                        appBar: const CommonAppBar(
                          title: '프로필 수정',
                          centerTitle: true,
                        ),
                        body: Center(
                          child: auth.memberStatus == MemberLoadStatus.error
                              ? MovieLogButton(
                                  label: '다시 시도',
                                  onPressed: () => auth.loadMember(force: true),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ChangeNotifierProvider<EditProfileViewModel>(
                      create: (context) => EditProfileViewModel(
                        context.read<MemberApiService>(),
                        auth,
                      ),
                      child: const EditProfileScreen(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static int indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}
