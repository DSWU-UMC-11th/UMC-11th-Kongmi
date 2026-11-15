class RatingDto {
  const RatingDto({
    required this.ratingId,
    required this.movieId,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  final int ratingId;
  final int movieId;
  final int score;
  final String? comment;
  final DateTime createdAt;

  factory RatingDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['ratingId'] ?? json['id'];
    final rawCreatedAt = json['createdAt'];
    return RatingDto(
      ratingId: (rawId as num).toInt(),
      movieId: (json['movieId'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: rawCreatedAt is String
          ? DateTime.parse(rawCreatedAt)
          : DateTime.now(),
    );
  }
}
