import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);
  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId;
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;

  int _requestVersion = 0;
  bool _disposed = false;

  bool get isLoading => status == MovieListLoadStatus.loading;

  Map<int, String> get genreNames => {for (final genre in genres) genre.id: genre.name};

  bool _isStale(int version) => _disposed || version != _requestVersion;

  Future<List<TmdbMovieDto>> _fetchUpToThirtyMovies({int? genreId}) async {
    final byId = <int, TmdbMovieDto>{};
    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < 30 && hasNextPage) {
      final page = await _service.discoverMovies(page: pageNumber, genreId: genreId);

      for (final movie in page.results) {
        byId[movie.id] = movie;
        if (byId.length == 30) break;
      }

      hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty;
      pageNumber++;
    }

    return byId.values.take(30).toList();
  }

  Future<void> loadInitial() async {
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    notifyListeners();

    try {
      if (genres.isEmpty) {
        genres = await _service.fetchGenres();
      }
      final result = await _fetchUpToThirtyMovies(genreId: selectedGenreId);
      if (_isStale(version)) return;
      movies = result;
      debugPrint('[MovieList] genre: $selectedGenreId, movies: ${movies.length}');
      status = result.isEmpty ? MovieListLoadStatus.empty : MovieListLoadStatus.success;
    } on DioException {
      if (_isStale(version)) return;
      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
    } catch (_) {
      if (_isStale(version)) return;
      status = MovieListLoadStatus.error;
      message = '데이터 처리 중 문제가 발생했어요.';
    }

    if (!_isStale(version)) notifyListeners();
  }

  Future<void> selectGenre(int? genreId) async {
    if (isLoading || genreId == selectedGenreId) return;

    selectedGenreId = genreId;
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    notifyListeners();

    try {
      final result = await _fetchUpToThirtyMovies(genreId: genreId);
      if (_isStale(version)) return;
      movies = result;
      debugPrint('[MovieList] genre: $selectedGenreId, movies: ${movies.length}');
      status = result.isEmpty ? MovieListLoadStatus.empty : MovieListLoadStatus.success;
    } on DioException {
      if (_isStale(version)) return;
      status = MovieListLoadStatus.error;
      message = '해당 장르 영화를 불러오지 못했어요.';
    } catch (_) {
      if (_isStale(version)) return;
      status = MovieListLoadStatus.error;
      message = '데이터 처리 중 문제가 발생했어요.';
    }

    if (!_isStale(version)) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}