import 'package:flutter/material.dart';

import '../view_models/load_phase.dart';
import '../view_models/paged_movies_view_model.dart';
import 'movielog_button.dart';

class MoviePageFooter extends StatelessWidget {
  const MoviePageFooter({
    super.key,
    required this.vm,
    this.moreLabel = '더 보기',
    this.endMessage = '모든 영화를 확인했습니다.',
  });

  final PagedMoviesViewModel vm;
  final String moreLabel;
  final String endMessage;

  @override
  Widget build(BuildContext context) {
    final hintStyle = TextStyle(fontSize: 13, color: Colors.grey.shade700);

    if (!vm.hasMore && !vm.isLoadingMore && vm.loadMoreError == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text(endMessage, textAlign: TextAlign.center, style: hintStyle),
      );
    }

    final error = vm.loadMoreError;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null) ...[
            Text(error, textAlign: TextAlign.center, style: hintStyle),
            const SizedBox(height: 12),
          ],
          MovieLogButton(
            width: double.infinity,
            label: error == null ? moreLabel : '다음 페이지 다시 시도',
            isLoading: vm.isLoadingMore,
            onPressed: vm.phase == LoadPhase.ready ? vm.loadNextPage : null,
          ),
        ],
      ),
    );
  }
}
