import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movielog_button.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내가 등록한 평점'),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.status) {
            case MyRatingsLoadStatus.idle:
            case MyRatingsLoadStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case MyRatingsLoadStatus.empty:
              return const Center(
                child: Text('아직 등록한 평점이 없습니다.', style: AppTextStyles.bodySmall),
              );
            case MyRatingsLoadStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewModel.message ?? '평점을 불러오지 못했습니다.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      MovieLogButton(
                        label: '다시 시도',
                        width: 120,
                        onPressed: viewModel.load,
                      ),
                    ],
                  ),
                ),
              );
            case MyRatingsLoadStatus.success:
              final notice = viewModel.message;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (notice != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(notice, style: AppTextStyles.bodySmall),
                    ),
                  for (final entry in viewModel.ratings)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RatingCard(entry: entry),
                    ),
                ],
              );
          }
        },
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  String _formatDate(DateTime dateTime) {
    final date = dateTime.toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    final movie = entry.movie;
    final rating = entry.rating;
    final posterPath = movie?.posterPath;
    final comment = rating.comment;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 72,
              height: 108,
              child: posterPath != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w200$posterPath',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: const Color(0xFFDAD3E0)),
                    )
                  : Container(color: const Color(0xFFDAD3E0)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  movie?.title ?? '영화 #${rating.movieId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '별점 ${rating.score} / 5',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet,
                  ),
                ),
                const SizedBox(height: 8),
                if (comment != null)
                  Text(
                    comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                if (posterPath == null)
                  const Text('포스터 정보 없음', style: AppTextStyles.bodySmall),
                const SizedBox(height: 6),
                Text(
                  _formatDate(rating.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}