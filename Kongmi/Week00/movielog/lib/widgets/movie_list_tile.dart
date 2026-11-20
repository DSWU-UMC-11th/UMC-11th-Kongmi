import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'tmdb_poster_image.dart';

const _posterPlaceholder = Color(0xFFEDE7F6);

class MovieListTile extends StatelessWidget {
  const MovieListTile({
    super.key,
    required this.title,
    required this.posterPath,
    this.subtitle,
    this.label,
    this.actionLabel,
    this.onAction,
    this.isActionLoading = false,
    this.showPoster = true,
    this.onTap,
  });

  final String title;
  final String? posterPath;
  final String? subtitle;
  final String? label;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isActionLoading;
  final bool showPoster;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.violet.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: showPoster
                    ? TmdbPosterImage(
                        posterPath: posterPath,
                        width: 72,
                        height: 108,
                      )
                    : Container(
                        width: 72,
                        height: 108,
                        color: _posterPlaceholder,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (label != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        label!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.violet,
                        ),
                      ),
                    ],
                    if (actionLabel != null) ...[
                      const SizedBox(height: 4),
                      isActionLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: SizedBox.square(
                                dimension: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.violet,
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: onAction,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  actionLabel!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.violet,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
