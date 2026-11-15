import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';
import 'rating_error_handler.dart';
import 'session_rating_store.dart';

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this._store,
    this._auth,
  ) {
    _store.addListener(_onStoreChanged);
    _loadMissingMovies();
  }

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final SessionRatingStore _store;
  final AuthViewModel _auth;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  final Set<int> _loadingMovieIds = {};
  bool _disposed = false;

  List<RatingWithMovie> get ratings => [
    for (final rating in _store.ratings)
      RatingWithMovie(rating: rating, movie: _movieCache[rating.movieId]),
  ];

  bool get isEmpty => _store.ratings.isEmpty;

  void _onStoreChanged() {
    _loadMissingMovies();
    _notify();
  }

  Future<void> _loadMissingMovies() async {
    final ids = {
      for (final rating in _store.ratings)
        if (!_movieCache.containsKey(rating.movieId) &&
            !_loadingMovieIds.contains(rating.movieId))
          rating.movieId,
    };
    for (final id in ids) {
      _loadingMovieIds.add(id);
      try {
        _movieCache[id] = await _movieService.findMovieById(id);
      } on DioException {
        _movieCache[id] = null;
      } finally {
        _loadingMovieIds.remove(id);
      }
      _notify();
    }
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final version = _auth.sessionVersion;
    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (version != _auth.sessionVersion) {
        throw StateError('로그인 세션이 바뀌어 결과를 반영하지 않았어요.');
      }
      _store.replace(version, updated);
    } on DioException catch (error) {
      throw StateError(
        await handleRatingError(
          error,
          auth: _auth,
          store: _store,
          sessionVersion: version,
          ratingId: ratingId,
        ),
      );
    }
  }

  Future<void> deleteRating(int ratingId) async {
    final version = _auth.sessionVersion;
    try {
      await _service.deleteRating(ratingId);
      if (version != _auth.sessionVersion) {
        throw StateError('로그인 세션이 바뀌어 결과를 반영하지 않았어요.');
      }
      _store.remove(version, ratingId);
    } on DioException catch (error) {
      throw StateError(
        await handleRatingError(
          error,
          auth: _auth,
          store: _store,
          sessionVersion: version,
          ratingId: ratingId,
        ),
      );
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }
}
