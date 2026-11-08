import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/models/rating_request.dart';
import '../data/services/rating_api_service.dart';
import '../theme/app_colors.dart';
import 'movie_rating_input.dart';
import 'movielog_button.dart';

const dialogSubtleColor = Color(0xFFEFEAF8);
const _commentFillColor = Color(0xFFF8F5FC);
const _commentBorderColor = Color(0xFFDDD6E8);
const _maxCommentLength = 500;

class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    this.initialScore = 0,
    this.initialComment,
    required this.onSubmit,
  });

  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _score = widget.initialScore;
  late final _commentController =
      TextEditingController(text: widget.initialComment ?? '');
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _commentBorderColor),
    );

    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '평점을 남겨주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: MovieRatingInput(
                  rating: _score.toDouble(),
                  enabled: !_isSubmitting,
                  onChanged: (value) => setState(
                    () => _score = validateServerScore(value),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '코멘트 (선택, 최대 500자)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: _maxCommentLength,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  hintText: '이 영화의 인상적인 장면은...',
                  filled: true,
                  fillColor: _commentFillColor,
                  contentPadding: const EdgeInsets.all(14),
                  border: border,
                  enabledBorder: border,
                  disabledBorder: border,
                  focusedBorder: border.copyWith(
                    borderSide: const BorderSide(color: AppColors.violet),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 4),
                Text(
                  _errorText!,
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      backgroundColor: dialogSubtleColor,
                      foregroundColor: AppColors.violet,
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MovieLogButton(
                      label: '확인',
                      isLoading: _isSubmitting,
                      onPressed: _score > 0 && !_isSubmitting ? _onConfirm : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    final trimmed = _commentController.text.trim();
    if (trimmed.length > _maxCommentLength) {
      setState(() => _errorText = '코멘트는 500자 이하로 입력해 주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.onSubmit(_score, trimmed.isEmpty ? null : trimmed);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = _messageOf(error);
      });
    }
  }

  String _messageOf(Object error) {
    if (error is DioException) return writeErrorMessage(error);
    if (error is StateError) return error.message;
    return '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
  }
}
