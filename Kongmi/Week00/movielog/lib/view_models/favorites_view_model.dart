import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/session/session_guard.dart';
import '../core/utils/map_bounded.dart';
import '../core/utils/safe_notify.dart';
import '../data/models/favorite_list_item.dart';
import '../data/models/favorite_response_dto.dart';
import '../data/services/favorite_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'load_phase.dart';

class FavoritesViewModel extends ChangeNotifier with SafeNotify {
  FavoritesViewModel({
    required this.favoriteApi,
    required this.tmdbApi,
    required this.sessionGuard,
    required this.accountId,
    this.onSessionExpired,
    this.enrichmentConcurrency = 5,
  });

  final FavoriteApiService favoriteApi;
  final TmdbMovieService tmdbApi;
  final SessionGuard sessionGuard;
  final String accountId;
  final Future<void> Function()? onSessionExpired;
  final int enrichmentConcurrency;

  LoadPhase phase = LoadPhase.idle;
  List<FavoriteListItem> items = const [];
  String? errorMessage;
  final Set<int> retryingMovieIds = {};
  int _refreshGeneration = 0;

  bool _isCurrent(int sessionGeneration, int refreshGeneration) =>
      sessionGuard.isCurrent(sessionGeneration, accountId) &&
      refreshGeneration == _refreshGeneration &&
      !isDisposed;

  Future<FavoriteListItem> _enrich(FavoriteResponseDto favorite) async {
    try {
      final movie = await tmdbApi.fetchMovieDetail(favorite.movieId);
      return FavoriteListItem(favorite: favorite, movie: movie);
    } catch (_) {
      return FavoriteListItem(
        favorite: favorite,
        errorMessage: '영화 정보를 불러오지 못했습니다.',
      );
    }
  }

  Future<void> refresh() async {
    final sessionGeneration = sessionGuard.generation;
    if (!sessionGuard.isCurrent(sessionGeneration, accountId) || isDisposed) {
      return;
    }
    final refreshGeneration = ++_refreshGeneration;
    if (phase != LoadPhase.ready) phase = LoadPhase.loading;
    errorMessage = null;
    retryingMovieIds.clear();
    notifyIfAlive();
    try {
      final favorites = await favoriteApi.fetchMyFavorites();
      if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
      final enriched = await mapBounded(
        favorites,
        enrichmentConcurrency,
        _enrich,
      );
      if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
      items = List.unmodifiable(enriched);
      phase = items.isEmpty ? LoadPhase.empty : LoadPhase.ready;
    } catch (error) {
      if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
      if (error is DioException && isSessionExpired(error)) {
        items = const [];
        phase = LoadPhase.error;
        errorMessage = '로그인이 만료됐어요. 다시 로그인해 주세요.';
        await onSessionExpired?.call();
        return;
      }
      items = const [];
      phase = LoadPhase.error;
      errorMessage = '즐겨찾기를 불러오지 못했습니다.';
    } finally {
      if (_isCurrent(sessionGeneration, refreshGeneration)) notifyIfAlive();
    }
  }

  Future<void> retryMovie(int movieId) async {
    final sessionGeneration = sessionGuard.generation;
    final refreshGeneration = _refreshGeneration;
    if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
    if (retryingMovieIds.contains(movieId)) return;
    final index = items.indexWhere((item) => item.favorite.movieId == movieId);
    if (index < 0) return;

    retryingMovieIds.add(movieId);
    notifyIfAlive();
    final updated = await _enrich(items[index].favorite);
    if (!_isCurrent(sessionGeneration, refreshGeneration)) return;
    retryingMovieIds.remove(movieId);
    final currentIndex = items.indexWhere(
      (item) => item.favorite.movieId == movieId,
    );
    if (currentIndex >= 0) {
      final next = [...items];
      next[currentIndex] = updated;
      items = List.unmodifiable(next);
    }
    notifyIfAlive();
  }
}
