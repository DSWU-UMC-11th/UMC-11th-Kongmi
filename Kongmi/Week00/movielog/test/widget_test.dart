// 1. Movie Class 작성
class Movie {
  final String title;
  final String? director; 

  Movie({required this.title, this.director});
}

void main() {
  // 2. 영화 3개를 List<Movie>에 추가
  List<Movie> movies = [
    Movie(title: '인셉션', director: '크리스토퍼 놀란'),
    Movie(title: '아바타', director: null), 
    Movie(title: '파묘', director: '장재현'),
  ];

  // 3. for 또는 map을 사용해 영화 제목 출력
  print('=== 영화 제목 목록 ===');
  for (var movie in movies) {
    print(movie.title);
  }

  print('\n=== 영화 정보 및 감독 ===');
  for (var movie in movies) {
    String safeDirector = movie.director ?? '미상';
    print('제목: ${movie.title} / 감독: $safeDirector');
  }
}