import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int? movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late final Movie? _movie = findMovieById(widget.movieId);
  late bool _isFavorite = _movie?.isFavorite ?? false;
  double _myRating = 0;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    _showSnackBar(_isFavorite ? '즐겨찾기에 추가했어요' : '즐겨찾기에서 삭제했어요');
  }

  Future<void> _openRatingDialog() async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => RatingDialog(initialRating: _myRating),
    );
    if (result == null || !mounted) return;
    setState(() => _myRating = result);
    _showSnackBar('평점 ${result.toStringAsFixed(1)}점을 남겼어요');
  }

  void _openShareSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('링크 복사'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showSnackBar('링크를 복사했어요');
              },
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('다른 앱으로 공유'),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/movies'); // URL로 바로 들어온 경우 대비
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movie;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        centerTitle: true,
        title: Text(
          'Cinema Archive',
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: movie == null ? null : _openShareSheet,
          ),
        ],
      ),
      body: movie == null
          ? const Center(child: Text('영화를 찾을 수 없어요. 목록에서 다시 선택해 주세요.'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Poster(asset: movie.posterAsset),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MovieHeader(movie: movie, myRating: _myRating),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        _Synopsis(text: movie.synopsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: movie == null
          ? null
          : _BottomActions(
              isFavorite: _isFavorite,
              onFavorite: _toggleFavorite,
              onRate: _openRatingDialog,
            ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: Colors.grey[300]),
      ),
    );
  }
}

class _MovieHeader extends StatelessWidget {
  const _MovieHeader({required this.movie, required this.myRating});

  final Movie movie;
  final double myRating;

  String _formatCount(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final subtle = textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text('${movie.year} • ${movie.genre} • ${movie.runtime}분', style: subtle),
        const SizedBox(height: 10),
        Row(
          children: [
            _StarRow(rating: movie.rating),
            const SizedBox(width: 6),
            Text(
              movie.rating.toStringAsFixed(1),
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Text('(${_formatCount(movie.ratingCount)})', style: subtle),
          ],
        ),
        if (myRating > 0) ...[
          const SizedBox(height: 6),
          Text(
            '내 평점 ${myRating.toStringAsFixed(1)}',
            style: textTheme.bodySmall?.copyWith(color: colors.primary),
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: movie.tags.map((tag) => _TagChip(label: tag)).toList(),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final IconData icon;
        if (rating >= i + 1) {
          icon = Icons.star_rounded;
        } else if (rating >= i + 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, size: 18, color: color);
      }),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}

class _Synopsis extends StatelessWidget {
  const _Synopsis({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시놉시스',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(text, style: textTheme.bodyMedium?.copyWith(height: 1.7)),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isFavorite,
    required this.onFavorite,
    required this.onRate,
  });

  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onFavorite,
                icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
                label: const Text('즐겨찾기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onRate,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('평점 남기기'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}