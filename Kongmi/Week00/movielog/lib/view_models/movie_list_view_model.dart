import 'package:flutter/foundation.dart';

import '../core/utils/safe_notify.dart';
import '../data/models/tmdb_genre_dto.dart';
import '../data/services/tmdb_movie_service.dart';

class MovieListViewModel extends ChangeNotifier with SafeNotify {
  MovieListViewModel(this._service);
  final TmdbMovieService _service;

  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId;
  bool _isLoadingGenres = false;

  Map<int, String> get genreNames => {
    for (final genre in genres) genre.id: genre.name,
  };

  Future<void> loadGenres() async {
    if (_isLoadingGenres || genres.isNotEmpty) return;
    _isLoadingGenres = true;
    try {
      final result = await _service.fetchGenres();
      if (isDisposed) return;
      genres = result;
      notifyIfAlive();
    } catch (_) {
      debugPrint('[MovieList] 장르 목록을 불러오지 못했습니다.');
    } finally {
      _isLoadingGenres = false;
    }
  }

  bool selectGenre(int? genreId) {
    if (genreId == selectedGenreId) return false;
    selectedGenreId = genreId;
    notifyIfAlive();
    return true;
  }
}
