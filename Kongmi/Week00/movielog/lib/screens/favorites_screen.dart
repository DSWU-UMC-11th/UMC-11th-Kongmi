import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/movie_format.dart';
import '../data/models/favorite_list_item.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/load_phase.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movie_list_tile.dart';
import '../widgets/movielog_button.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.onOpenMovie});

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritesViewModel>().refresh();
    });
  }

  Future<void> _open(FavoritesViewModel vm, TmdbMovieDto movie) async {
    await widget.onOpenMovie(movie);
    if (!mounted) return;
    await vm.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '내 즐겨찾기',
        centerTitle: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, vm, _) {
          switch (vm.phase) {
            case LoadPhase.idle:
            case LoadPhase.loading:
              return const Center(child: CircularProgressIndicator());
            case LoadPhase.empty:
              return const _EmptyFavorites();
            case LoadPhase.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vm.errorMessage ?? '즐겨찾기를 불러오지 못했습니다.',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      MovieLogButton(
                        width: 220,
                        label: '다시 시도',
                        onPressed: vm.refresh,
                      ),
                    ],
                  ),
                ),
              );
            case LoadPhase.ready:
              return RefreshIndicator(
                onRefresh: vm.refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildItem(vm, vm.items[index]),
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildItem(FavoritesViewModel vm, FavoriteListItem item) {
    final movie = item.movie;
    final movieId = item.favorite.movieId;
    final savedAt = _formatDate(item.favorite.createdAt);

    if (movie == null) {
      return MovieListTile(
        title: '영화 #$movieId',
        posterPath: null,
        showPoster: false,
        subtitle: item.errorMessage ?? '영화 정보가 없습니다.',
        label: '즐겨찾기한 영화 · $savedAt',
        actionLabel: '정보 다시 불러오기',
        isActionLoading: vm.retryingMovieIds.contains(movieId),
        onAction: () => vm.retryMovie(movieId),
      );
    }

    return MovieListTile(
      title: movie.title,
      posterPath: movie.posterPath,
      subtitle: movieYear(movie),
      label: '즐겨찾기한 영화 · $savedAt',
      onTap: () => _open(vm, movie),
    );
  }

  String _formatDate(DateTime dateTime) {
    final date = dateTime.toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark_border, size: 36, color: AppColors.violet),
          const SizedBox(height: 16),
          const Text(
            '아직 즐겨찾기한 영화가 없습니다.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '영화 상세에서 북마크를 눌러보세요.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
