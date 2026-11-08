import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/utils/movie_format.dart';
import '../view_models/movie_detail_view_model.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key});

  Future<void> _openRatingDialog(BuildContext context) async {
    final viewModel = context.read<MovieDetailViewModel>();
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
        },
      ),
    );

    if (!context.mounted) return;
    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.'),
        ),
      );
      return;
    }
    if (viewModel.submitStatus == SubmitStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.submitMessage ?? '평점을 등록하지 못했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MovieDetailViewModel>();
    final movie = viewModel.movie;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!viewModel.canRate)
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('평점을 남기려면 학습용 회원가입이 필요합니다. 회원가입하기'),
              ),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(shape: const StadiumBorder()),
                onPressed: viewModel.canRate ? () => _openRatingDialog(context) : null,
                icon: const Icon(Icons.star_outline),
                label: const Text('평점 남기기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
