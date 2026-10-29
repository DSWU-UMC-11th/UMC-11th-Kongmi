import '../../data/models/tmdb_movie_dto.dart';

String? movieYear(TmdbMovieDto movie) {
  final date = movie.releaseDate;
  if (date == null || date.length < 4) return null;
  return date.substring(0, 4);
}

String movieSubtitle(TmdbMovieDto movie, Map<int, String> genreNames) {
  final parts = <String>[];
  final year = movieYear(movie);
  if (year != null) parts.add(year);
  for (final id in movie.genreIds) {
    final name = genreNames[id];
    if (name != null) {
      parts.add(name);
      break;
    }
  }
  return parts.join(' · ');
}

String ratingLabel(double voteAverage) => (voteAverage / 2).toStringAsFixed(1);
