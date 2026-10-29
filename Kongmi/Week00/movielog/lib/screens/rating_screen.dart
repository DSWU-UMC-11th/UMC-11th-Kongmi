import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key, required this.movieId});

  final int movieId;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    final canSave = _rating > 0;

    return Scaffold(
      appBar: const CommonAppBar(
        title: '평점 남기기',
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '영화를 재미있게 보셨나요?\n평점을 선택해 주세요.',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 32),
              RatingBar.builder(
                initialRating: 0,
                minRating: 0.5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                _rating > 0 ? '$_rating / 5.0 점' : '별점을 선택해주세요',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: canSave
                    ? () {
                        debugPrint('[Rating] movieId: ${widget.movieId}, score: $_rating');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$_rating점 평점이 저장되었습니다!')),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  disabledBackgroundColor: AppColors.violet.withValues(alpha: 0.3),
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('평점 저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}