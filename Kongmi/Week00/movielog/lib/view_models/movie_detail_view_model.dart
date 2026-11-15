import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';
import 'rating_error_handler.dart';
import 'session_rating_store.dart';
import 'submit_status.dart';

export 'submit_status.dart';

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._store,
    this._auth,
    this.movie,
  );
  final RatingApiService _ratingService;
  final SessionRatingStore _store;
  final AuthViewModel _auth;
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  Future<void> createRating({required int score, String? comment}) async {
    if (submitStatus == SubmitStatus.submitting) return;
    final version = _auth.sessionVersion;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    _notify();

    try {
      final created = await _ratingService.createRating(
        CreateRatingRequest(movieId: movie.id, score: score, comment: comment),
      );
      if (version != _auth.sessionVersion) {
        throw StateError('로그인 세션이 바뀌어 결과를 반영하지 않았어요.');
      }
      _store.add(version, created);
      if (_disposed) return;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      final text = await handleRatingError(
        error,
        auth: _auth,
        store: _store,
        sessionVersion: version,
      );
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = text;
    } on StateError catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = error.message;
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
