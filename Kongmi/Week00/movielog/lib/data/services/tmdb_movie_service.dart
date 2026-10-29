import 'package:dio/dio.dart';

import '../models/tmdb_genre_dto.dart';
import '../models/tmdb_movie_page_dto.dart';

class TmdbMovieService {
  TmdbMovieService(this._dio);
  final Dio _dio;

  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    final response = await _dio.get(
      '/movie/popular',
      queryParameters: {'language': 'ko-KR', 'page': page},
    );
    return TmdbMoviePageDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    int? genreId,
  }) async {
    final response = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'language': 'ko-KR',
        'page': page,
        'sort_by': 'popularity.desc',
        'include_adult': false,
        'include_video': false,
        'with_genres': ?genreId,
      },
    );
    return TmdbMoviePageDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TmdbGenreDto>> fetchGenres() async {
    final response = await _dio.get(
      '/genre/movie/list',
      queryParameters: {'language': 'ko'},
    );
    final data = response.data as Map<String, dynamic>;
    final genres = data['genres'] as List<dynamic>? ?? const [];
    return genres
        .map((item) => TmdbGenreDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
