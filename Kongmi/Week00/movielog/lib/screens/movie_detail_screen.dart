import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/movie_format.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId, this.movie});

  final int? movieId;
  final TmdbMovieDto? movie;

  @override
  Widget build(BuildContext context) {
    final movie = this.movie;
    final movieId = this.movieId;

    if (movie == null || movieId == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('영화 정보를 찾을 수 없어요.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/movies'),
                child: const Text('목록으로'),
              ),
            ],
          ),
        ),
      );
    }

    final year = movieYear(movie);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('영화 상세', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TmdbPosterImage(
                posterPath: movie.posterPath,
                width: 200,
                height: 300,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            movie.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (year != null) ...[
                Text(year, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(width: 12),
              ],
              Icon(Icons.star, size: 16, color: primary),
              const SizedBox(width: 4),
              Text(
                ratingLabel(movie.voteAverage),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text('줄거리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (movie.overview.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  '줄거리 정보가 없어요.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            Text(movie.overview, style: const TextStyle(height: 1.6)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(shape: const StadiumBorder()),
            onPressed: () => context.push('/movies/$movieId/rating'),
            icon: const Icon(Icons.star_outline),
            label: const Text('평점 남기기'),
          ),
        ),
      ),
    );
  }
}