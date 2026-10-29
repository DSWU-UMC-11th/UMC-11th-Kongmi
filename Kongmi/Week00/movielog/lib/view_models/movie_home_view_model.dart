import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieHomeLoadStatus { idle, loading, success, empty, error }

class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this._service);
  final TmdbMovieService _service;

  List<TmdbMovieDto> popularMovies = const [];
  Map<int, String> genreNames = const {};
  MovieHomeLoadStatus status = MovieHomeLoadStatus.idle;
  String? message;
  bool _disposed = false;

  TmdbMovieDto? get featuredMovie => popularMovies.isEmpty ? null : popularMovies.first;

  Future<void> loadPopular() async {
    status = MovieHomeLoadStatus.loading;
    notifyListeners();

    try {
      final page = await _service.fetchPopular();
      final genres = await _service.fetchGenres();
      if (_disposed) return;
      popularMovies = page.results.take(5).toList();
      genreNames = {for (final genre in genres) genre.id: genre.name};
      status = popularMovies.isEmpty ? MovieHomeLoadStatus.empty : MovieHomeLoadStatus.success;
    } on DioException {
      if (_disposed) return;
      status = MovieHomeLoadStatus.error;
      message = '인기 영화를 불러오지 못했어요.';
    } catch (_) {
      if (_disposed) return;
      status = MovieHomeLoadStatus.error;
      message = '데이터 처리 중 문제가 발생했어요.';
    }

    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}