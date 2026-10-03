import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final double rating;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBar.builder(
          initialRating: rating,
          minRating: 0.5,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 36,
          itemPadding: const EdgeInsets.symmetric(horizontal: 2),
          itemBuilder: (context, _) =>
              Icon(Icons.star_rounded, color: colors.primary),
          onRatingUpdate: onChanged,
        ),
        const SizedBox(height: 8),
        Text(
          rating == 0 ? '별을 눌러 평점을 선택하세요' : '${rating.toStringAsFixed(1)}점',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}