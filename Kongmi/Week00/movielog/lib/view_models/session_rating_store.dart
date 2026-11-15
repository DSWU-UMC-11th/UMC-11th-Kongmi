import 'package:flutter/foundation.dart';

import '../data/models/rating_dto.dart';

class SessionRatingStore extends ChangeNotifier {
  int? _sessionVersion;
  final List<RatingDto> _ratings = [];

  List<RatingDto> get ratings => List.unmodifiable(_ratings);
  int? get sessionVersion => _sessionVersion;

  void syncSession(int? version) {
    if (version == _sessionVersion) return;
    _sessionVersion = version;
    _ratings.clear();
    notifyListeners();
  }

  bool _accepts(int version) =>
      _sessionVersion != null && version == _sessionVersion;

  void add(int version, RatingDto rating) {
    if (!_accepts(version)) return;
    _ratings
      ..removeWhere((item) => item.ratingId == rating.ratingId)
      ..insert(0, rating);
    notifyListeners();
  }

  void replace(int version, RatingDto rating) {
    if (!_accepts(version)) return;
    final index = _ratings.indexWhere(
      (item) => item.ratingId == rating.ratingId,
    );
    if (index < 0) return;
    _ratings[index] = rating;
    notifyListeners();
  }

  void remove(int version, int ratingId) {
    if (!_accepts(version)) return;
    final before = _ratings.length;
    _ratings.removeWhere((item) => item.ratingId == ratingId);
    if (_ratings.length != before) notifyListeners();
  }
}
