import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/utils/movie_format.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../view_models/movie_home_view_model.dart';
import '../widgets/state_message.dart';
import '../widgets/tmdb_poster_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MovieLog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Consumer<MovieHomeViewModel>(
        builder: (context, vm, _) {
          return switch (vm.status) {
            MovieHomeLoadStatus.idle ||
            MovieHomeLoadStatus.loading => const Center(child: CircularProgressIndicator()),
            MovieHomeLoadStatus.error => StateMessage(
                message: vm.message ?? '오류가 발생했어요.',
                onRetry: () => context.read<MovieHomeViewModel>().loadPopular(),
              ),
            MovieHomeLoadStatus.empty => const StateMessage(message: '표시할 영화가 없어요.'),
            MovieHomeLoadStatus.success => _HomeContent(vm: vm),
          };
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.vm});

  final MovieHomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final featured = vm.featuredMovie!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘은 어떤\n영화를 볼까요?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 16),
          _FeaturedCard(
            movie: featured,
            subtitle: movieSubtitle(featured, vm.genreNames),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '인기 영화',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.go('/movies'),
                child: const Text('전체보기 >'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: vm.popularMovies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final movie = vm.popularMovies[index];
                return _PopularCard(rank: index + 1, movie: movie);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.movie, required this.subtitle});

  final TmdbMovieDto movie;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => context.push('/movies/${movie.id}', extra: movie),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TmdbPosterImage(
                posterPath: movie.posterPath,
                width: double.infinity,
                height: double.infinity,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.45, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '추천 신작',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => context.push('/movies/${movie.id}', extra: movie),
                        icon: const Icon(Icons.info, size: 18),
                        label: const Text('상세보기'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.rank, required this.movie});

  final int rank;
  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/movies/${movie.id}', extra: movie),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TmdbPosterImage(
                      posterPath: movie.posterPath,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}