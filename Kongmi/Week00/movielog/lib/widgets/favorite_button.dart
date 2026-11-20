import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/favorite_detail_view_model.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  Future<void> _toggle(BuildContext context, FavoriteDetailViewModel vm) async {
    final messenger = ScaffoldMessenger.of(context);
    await vm.toggle();
    if (!context.mounted || vm.isDisposed) return;
    final message = vm.errorMessage ?? vm.resultMessage;
    if (message == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteDetailViewModel>(
      builder: (context, vm, _) {
        final needsReload = vm.canRetryLoad;
        final VoidCallback? onTap = vm.isBusy
            ? null
            : needsReload
            ? vm.load
            : vm.hasLoadedStatus
            ? () => _toggle(context, vm)
            : null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.gray.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: SizedBox(
                  width: 62,
                  height: 64,
                  child: Center(
                    child: vm.isBusy
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.violet,
                            ),
                          )
                        : Icon(
                            needsReload
                                ? Icons.refresh
                                : vm.isFavorite
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 30,
                            color: AppColors.violet,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              needsReload ? '다시 확인' : '즐겨찾기',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.violet,
              ),
            ),
          ],
        );
      },
    );
  }
}
