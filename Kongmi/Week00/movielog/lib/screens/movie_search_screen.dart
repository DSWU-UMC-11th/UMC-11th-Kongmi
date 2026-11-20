import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/movie_format.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../view_models/load_phase.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movie_list_tile.dart';
import '../widgets/movie_page_footer.dart';
import '../widgets/movielog_button.dart';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key, required this.onOpenMovie});

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final _controller = TextEditingController();
  String? _inputError;

  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      setState(() => _inputError = '검색어를 입력해 주세요.');
      return;
    }
    setState(() => _inputError = null);
    FocusScope.of(context).unfocus();
    context.read<PagedMoviesViewModel>().loadInitial(query: query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '영화 검색',
        centerTitle: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              decoration: InputDecoration(
                hintText: '영화 제목을 입력하세요',
                errorText: _inputError,
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.violet.withValues(alpha: 0.2),
                  ),
                ),
                suffixIcon: TextButton(
                  onPressed: () => _submitSearch(_controller.text),
                  child: const Text(
                    '검색',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<PagedMoviesViewModel>(
              builder: (context, vm, _) {
                switch (vm.phase) {
                  case LoadPhase.idle:
                    return _CenterMessage(
                      message: '검색어를 입력하고 검색을 눌러 주세요.',
                      color: Colors.grey.shade600,
                    );
                  case LoadPhase.loading:
                    return const Center(child: CircularProgressIndicator());
                  case LoadPhase.error:
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              vm.errorMessage ?? '검색 결과를 불러오지 못했습니다.',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            MovieLogButton(
                              width: 220,
                              label: '다시 시도',
                              onPressed: vm.retryInitial,
                            ),
                          ],
                        ),
                      ),
                    );
                  case LoadPhase.empty:
                    return const _CenterMessage(message: '검색 결과가 없습니다.');
                  case LoadPhase.ready:
                    return ListView.builder(
                      key: PageStorageKey('search-${vm.query}'),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      itemCount: vm.movies.length + 1,
                      itemBuilder: (context, index) {
                        if (index == vm.movies.length) {
                          return MoviePageFooter(
                            vm: vm,
                            moreLabel: '검색 결과 더 보기',
                            endMessage: '모든 검색 결과를 확인했습니다.',
                          );
                        }
                        final movie = vm.movies[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MovieListTile(
                            title: movie.title,
                            posterPath: movie.posterPath,
                            subtitle: movieYear(movie),
                            label: '★ ${ratingLabel(movie.voteAverage)}',
                            onTap: () => widget.onOpenMovie(movie),
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterMessage extends StatelessWidget {
  const _CenterMessage({required this.message, this.color});

  final String message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: color ?? Colors.grey.shade800,
        ),
      ),
    );
  }
}
