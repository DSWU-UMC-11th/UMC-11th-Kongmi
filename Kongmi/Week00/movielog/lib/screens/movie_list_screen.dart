import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/utils/movie_format.dart';
import '../view_models/load_phase.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/movie_grid_card.dart';
import '../widgets/movie_page_footer.dart';
import '../widgets/state_message.dart';

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
          IconButton(
            tooltip: '영화 검색',
            icon: Icon(Icons.search, color: primary),
            onPressed: () => context.push('/movies/search'),
          ),
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

  void _select(BuildContext context, int? genreId) {
    final changed = context.read<MovieListViewModel>().selectGenre(genreId);
    if (!changed) return;
    context.read<PagedMoviesViewModel>().loadInitial(genreId: genreId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListViewModel>(
      builder: (context, vm, _) {
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _GenreChip(
                label: '전체',
                selected: vm.selectedGenreId == null,
                onTap: () => _select(context, null),
              ),
              for (final genre in vm.genres) ...[
                const SizedBox(width: 8),
                _GenreChip(
                  label: genre.name,
                  selected: vm.selectedGenreId == genre.id,
                  onTap: () => _select(context, genre.id),
                ),
              ],
            ],
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
    final genreNames = context.watch<MovieListViewModel>().genreNames;

    return Consumer<PagedMoviesViewModel>(
      builder: (context, vm, _) {
        switch (vm.phase) {
          case LoadPhase.idle:
          case LoadPhase.loading:
            return const Center(child: CircularProgressIndicator());
          case LoadPhase.error:
            return StateMessage(
              message: vm.errorMessage ?? '영화 목록을 불러오지 못했습니다.',
              onRetry: vm.retryInitial,
            );
          case LoadPhase.empty:
            return const StateMessage(message: '해당 조건의 영화가 없어요.');
          case LoadPhase.ready:
            return CustomScrollView(
              key: PageStorageKey('movie-grid-${vm.genreId}'),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        subtitle: movieSubtitle(movie, genreNames),
                        onTap: () =>
                            context.push('/movies/${movie.id}', extra: movie),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(child: MoviePageFooter(vm: vm)),
              ],
            );
        }
      },
    );
  }
}
