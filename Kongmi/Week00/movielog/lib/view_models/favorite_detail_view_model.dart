import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/session/session_guard.dart';
import '../core/utils/safe_notify.dart';
import '../data/services/favorite_api_service.dart';

class FavoriteDetailViewModel extends ChangeNotifier with SafeNotify {
  FavoriteDetailViewModel({
    required this.movieId,
    required this.favoriteApi,
    required this.sessionGuard,
    required this.accountId,
    this.onSessionExpired,
  });

  final int movieId;
  final FavoriteApiService favoriteApi;
  final SessionGuard sessionGuard;
  final String accountId;
  final Future<void> Function()? onSessionExpired;

  bool isFavorite = false;
  bool hasLoadedStatus = false;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? resultMessage;

  bool get isBusy => isLoading || isSaving;

  bool get canRetryLoad =>
      !hasLoadedStatus && !isLoading && errorMessage != null;

  ({int generation, bool ok}) _snapshot() {
    final generation = sessionGuard.generation;
    return (generation: generation, ok: _isCurrent(generation));
  }

  bool _isCurrent(int generation) =>
      sessionGuard.isCurrent(generation, accountId) && !isDisposed;

  Future<bool> _handleSessionExpired(Object error) async {
    if (error is! DioException || !isSessionExpired(error)) return false;
    errorMessage = '로그인이 만료됐어요. 다시 로그인해 주세요.';
    await onSessionExpired?.call();
    return true;
  }

  Future<void> load() async {
    if (isBusy) return;
    final snap = _snapshot();
    if (!snap.ok) return;
    isLoading = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      final result = await favoriteApi.checkFavorite(movieId: movieId);
      if (!_isCurrent(snap.generation)) return;
      isFavorite = result.isFavorite;
      hasLoadedStatus = true;
    } catch (error) {
      if (!_isCurrent(snap.generation)) return;
      if (await _handleSessionExpired(error)) return;
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } finally {
      if (_isCurrent(snap.generation)) {
        isLoading = false;
        notifyIfAlive();
      }
    }
  }

  Future<void> toggle() async {
    if (isBusy || !hasLoadedStatus) return;
    final snap = _snapshot();
    if (!snap.ok) return;
    final before = isFavorite;
    isSaving = true;
    errorMessage = null;
    resultMessage = null;
    notifyIfAlive();
    try {
      if (before) {
        await favoriteApi.deleteFavorite(movieId: movieId);
      } else {
        await favoriteApi.addFavorite(movieId: movieId);
      }
      if (!_isCurrent(snap.generation)) return;
      isFavorite = !before;
      resultMessage = isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.';
    } on DioException catch (error) {
      if (!_isCurrent(snap.generation)) return;
      if (await _handleSessionExpired(error)) return;
      final code = apiErrorCode(error);
      if (code == 'FAVORITE409_1' || code == 'FAVORITE404_1') {
        await _syncWithServer(snap.generation, before);
      } else {
        isFavorite = before;
        errorMessage = _failureMessage(before);
      }
    } catch (_) {
      if (!_isCurrent(snap.generation)) return;
      isFavorite = before;
      errorMessage = _failureMessage(before);
    } finally {
      if (_isCurrent(snap.generation)) {
        isSaving = false;
        notifyIfAlive();
      }
    }
  }

  Future<void> _syncWithServer(int generation, bool before) async {
    try {
      final synced = await favoriteApi.checkFavorite(movieId: movieId);
      if (!_isCurrent(generation)) return;
      isFavorite = synced.isFavorite;
      resultMessage = isFavorite ? '이미 즐겨찾기한 영화입니다.' : '이미 즐겨찾기에서 삭제된 영화입니다.';
    } catch (error) {
      if (!_isCurrent(generation)) return;
      if (await _handleSessionExpired(error)) return;
      isFavorite = before;
      errorMessage = '서버 상태를 다시 확인하지 못했습니다. 다시 시도해 주세요.';
    }
  }

  String _failureMessage(bool before) => before
      ? '즐겨찾기를 해제하지 못했습니다. 다시 시도해 주세요.'
      : '즐겨찾기에 저장하지 못했습니다. 다시 시도해 주세요.';
}
