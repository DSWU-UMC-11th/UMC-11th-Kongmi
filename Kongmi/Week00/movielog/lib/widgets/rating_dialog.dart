import 'package:flutter/material.dart';
import 'movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, this.initialRating = 0.0});

  final double initialRating;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '영화 평점 남기기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            MovieRatingInput(
              rating: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed:
                      _rating == 0 ? null : () => Navigator.pop(context, _rating),
                  child: const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}