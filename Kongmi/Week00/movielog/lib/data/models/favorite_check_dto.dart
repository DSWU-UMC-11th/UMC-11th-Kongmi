class FavoriteCheckDto {
  const FavoriteCheckDto({required this.movieId, required this.isFavorite});

  factory FavoriteCheckDto.fromJson(Object? json, {required int movieId}) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('FavoriteCheckDto must be a JSON object.');
    }
    final isFavorite = json['isFavorite'];
    if (isFavorite is! bool) {
      throw const FormatException('isFavorite must be a boolean.');
    }
    return FavoriteCheckDto(movieId: movieId, isFavorite: isFavorite);
  }

  final int movieId;
  final bool isFavorite;
}
