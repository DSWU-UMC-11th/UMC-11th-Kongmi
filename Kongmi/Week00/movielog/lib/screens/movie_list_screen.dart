import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/utils/movie_format.dart';
import '../view_models/movie_list_view_model.dart';
import '../widgets/movie_grid_card.dart';
import '../widgets/state_message.dart';
import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import '../storage/genre_preference.dart';
import '../widgets/genre_chip_bar.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';

enum _DebugScenario { success, empty, failure, failThenRetrySuccess }

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          '영화',
          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: Icon(Icons.search, color: primary), onPressed: () {}),
        ],
      ),
      body: const Column(
        children: [
          _GenreChips(),
          SizedBox(height: 8),
          Expanded(child: _MovieGridArea()),
        ],
      ),
    );
  }
}

class _GenreChips extends StatelessWidget {
  const _GenreChips();

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListViewModel>(
      builder: (context, vm, _) {
        return AbsorbPointer(
          absorbing: vm.isLoading,
          child: Opacity(
            opacity: vm.isLoading ? 0.5 : 1,
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _GenreChip(
                    label: '전체',
                    selected: vm.selectedGenreId == null,
                    onTap: () => vm.selectGenre(null),
                  ),
                  for (final genre in vm.genres) ...[
                    const SizedBox(width: 8),
                    _GenreChip(
                      label: genre.name,
                      selected: vm.selectedGenreId == genre.id,
                      onTap: () => vm.selectGenre(genre.id),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: primary,
      backgroundColor: primary.withValues(alpha: 0.12),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}

class _MovieGridArea extends StatelessWidget {
  const _MovieGridArea();

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListViewModel>(
      builder: (context, vm, _) {
        return switch (vm.status) {
          MovieListLoadStatus.idle ||
          MovieListLoadStatus.loading => const Center(child: CircularProgressIndicator()),
          MovieListLoadStatus.error => StateMessage(
              message: vm.message ?? '오류가 발생했어요.',
              onRetry: () => context.read<MovieListViewModel>().loadInitial(),
            ),
          MovieListLoadStatus.empty => const StateMessage(message: '해당 조건의 영화가 없어요.'),
          MovieListLoadStatus.success => GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 12,
                childAspectRatio: 0.55,
              ),
              itemCount: vm.movies.length,
              itemBuilder: (context, index) {
                final movie = vm.movies[index];
                return MovieGridCard(
                  movie: movie,
                  subtitle: movieSubtitle(movie, vm.genreNames),
                  onTap: () => context.push('/movies/${movie.id}', extra: movie),
                );
              },
            ),
        };
      },
    );
  }
}