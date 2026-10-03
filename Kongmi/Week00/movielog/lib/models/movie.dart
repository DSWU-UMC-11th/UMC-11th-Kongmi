class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    this.rating = 0.0,
    this.isFavorite = false,
    this.runtime = 0,
    this.ratingCount = 0,
    this.tags = const [],
    this.synopsis = '',
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final double rating;
  final bool isFavorite;

  final int runtime;
  final int ratingCount;
  final List<String> tags;
  final String synopsis;
}

const String _posterDir = 'assets/images/posters';

const mockMovies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '로맨스/드라마',
    year: 2024,
    posterAsset: '$_posterDir/poster_echoes_of_the_void.jpg',
    rating: 4.5,
    runtime: 124,
    ratingCount: 1245,
    tags: ['로맨스', '드라마', '감동적인'],
    synopsis: '도시의 불빛이 닿지 않는 언덕에서, 서로 다른 상처를 가진 두 사람이 '
        '우연히 같은 밤하늘을 올려다보게 된다. 매일 밤 별을 세며 이야기를 나누던 '
        '두 사람은 조금씩 서로의 빈자리를 채워 간다.\n\n'
        '하지만 떠나야 하는 날이 다가오면서, 두 사람은 지금의 마음을 지킬지 '
        '각자의 길을 갈지 선택해야 한다. 별빛 아래에서 시작된 이야기는 어떤 '
        '결말을 맞이할까.',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: '$_posterDir/poster_abyss_walker.jpg',
    rating: 4.2,
    runtime: 138,
    ratingCount: 982,
    tags: ['SF', '모험', '웅장한'],
    synopsis: '연락이 끊긴 탐사선을 찾아 떠난 우주비행사가 우주의 끝에서 '
        '예상하지 못한 신호를 발견한다.',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2022,
    posterAsset: '$_posterDir/poster_whispering_woods.jpg',
    rating: 4.9,
    runtime: 102,
    ratingCount: 2310,
    tags: ['애니메이션', '판타지', '따뜻한'],
    synopsis: '잃어버린 기억을 찾기 위해 말하는 숲으로 들어간 소녀의 모험 이야기.',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: '$_posterDir/poster_night_shadows.jpg',
    rating: 3.8,
    runtime: 115,
    ratingCount: 654,
    tags: ['스릴러', '미스터리', '긴장감'],
    synopsis: '비 내리는 도시의 골목에서 벌어진 사건을 쫓는 형사의 하룻밤.',
  ),
  Movie(
    id: 5,
    title: '네 번째 오후',
    genre: '로맨스',
    year: 2021,
    posterAsset: '$_posterDir/poster_fourth_afternoon.jpg',
    rating: 4.5,
    runtime: 109,
    ratingCount: 1102,
    tags: ['로맨스', '일상', '잔잔한'],
    synopsis: '매주 같은 카페, 같은 시간에 마주치는 두 사람의 네 번째 오후.',
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}