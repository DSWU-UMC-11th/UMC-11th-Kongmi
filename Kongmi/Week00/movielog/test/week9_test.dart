import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/core/utils/map_bounded.dart';
import 'package:movielog/data/models/favorite_check_dto.dart';
import 'package:movielog/data/models/favorite_response_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/models/tmdb_movie_page_dto.dart';
import 'package:movielog/data/services/favorite_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/favorite_detail_view_model.dart';
import 'package:movielog/view_models/favorites_view_model.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';

TmdbMovieDto movie(int id) => TmdbMovieDto(
  id: id,
  title: '영화 $id',
  overview: '',
  posterPath: null,
  backdropPath: null,
  releaseDate: '2025-01-01',
  genreIds: const [],
  voteAverage: 8,
  popularity: 1,
);

TmdbMoviePageDto page(int number, List<int> ids, {int totalPages = 3}) =>
    TmdbMoviePageDto(
      page: number,
      results: ids.map(movie).toList(),
      totalPages: totalPages,
      totalResults: ids.length,
    );

DioException apiError(String code, int status) {
  final options = RequestOptions(path: '/v8/favorites');
  return DioException(
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: status,
      data: {'isSuccess': false, 'code': code, 'message': code},
    ),
  );
}

class FakeTmdb extends TmdbMovieService {
  FakeTmdb() : super(Dio());

  final Map<String, Completer<TmdbMoviePageDto>> pending = {};
  final Set<int> failingDetails = {};
  final List<int> requestedPages = [];

  Completer<TmdbMoviePageDto> _complete(String key) =>
      pending.putIfAbsent(key, Completer<TmdbMoviePageDto>.new);

  @override
  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    int? genreId,
  }) {
    requestedPages.add(page);
    return _complete('d:$genreId:$page').future;
  }

  @override
  Future<TmdbMoviePageDto> searchMovies({
    required int page,
    required String query,
  }) {
    requestedPages.add(page);
    return _complete('s:$query:$page').future;
  }

  @override
  Future<TmdbMovieDto> fetchMovieDetail(int movieId) async {
    if (failingDetails.contains(movieId)) throw Exception('tmdb');
    return movie(movieId);
  }
}

class FakeFavoriteApi extends FavoriteApiService {
  FakeFavoriteApi() : super(Dio());

  bool serverValue = false;
  Object? addError;
  List<FavoriteResponseDto> list = [];

  @override
  Future<FavoriteCheckDto> checkFavorite({required int movieId}) async =>
      FavoriteCheckDto(movieId: movieId, isFavorite: serverValue);

  @override
  Future<FavoriteResponseDto> addFavorite({required int movieId}) async {
    final error = addError;
    if (error != null) throw error;
    serverValue = true;
    return FavoriteResponseDto(
      favoriteId: 1,
      movieId: movieId,
      createdAt: DateTime(2026),
    );
  }

  @override
  Future<void> deleteFavorite({required int movieId}) async {
    serverValue = false;
  }

  @override
  Future<List<FavoriteResponseDto>> fetchMyFavorites() async => list;
}

void main() {
  group('mapBounded', () {
    test('순서를 유지하고 동시 실행 수를 제한한다', () async {
      var running = 0;
      var maxRunning = 0;
      final result = await mapBounded<int, int>(
        List.generate(12, (i) => i),
        5,
        (value) async {
          running++;
          if (running > maxRunning) maxRunning = running;
          await Future<void>.delayed(const Duration(milliseconds: 5));
          running--;
          return value * 2;
        },
      );
      expect(result, List.generate(12, (i) => i * 2));
      expect(maxRunning, lessThanOrEqualTo(5));
    });
  });

  group('SessionGuard', () {
    test('같은 이메일이라도 새 세션이면 이전 generation은 무효다', () {
      final guard = SessionGuard();
      final first = guard.startSession('a@example.com');
      guard.invalidate();
      final second = guard.startSession('a@example.com');
      expect(guard.isCurrent(first, 'a@example.com'), isFalse);
      expect(guard.isCurrent(second, 'a@example.com'), isTrue);
    });
  });

  group('PagedMoviesViewModel', () {
    test('다음 page 실패 시 nextPage를 유지하고 같은 page를 다시 요청한다', () async {
      final tmdb = FakeTmdb();
      final vm = PagedMoviesViewModel(tmdbApi: tmdb);

      final first = vm.loadInitial();
      tmdb.pending['d:null:1']!.complete(page(1, [1, 2]));
      await first;
      expect(vm.phase, LoadPhase.ready);
      expect(vm.nextPage, 2);

      final failed = vm.loadNextPage();
      expect(vm.isLoadingMore, isTrue);
      tmdb.pending.remove('d:null:2')!.completeError(Exception('network'));
      await failed;
      expect(vm.nextPage, 2);
      expect(vm.loadMoreError, isNotNull);
      expect(vm.movies.length, 2);

      final retry = vm.loadNextPage();
      tmdb.pending['d:null:2']!.complete(page(2, [2, 3]));
      await retry;
      expect(vm.movies.map((m) => m.id), [1, 2, 3]);
      expect(vm.nextPage, 3);
      expect(tmdb.requestedPages, [1, 2, 2]);
    });

    test('조건이 바뀐 뒤 늦게 도착한 이전 응답은 무시한다', () async {
      final tmdb = FakeTmdb();
      final vm = PagedMoviesViewModel(tmdbApi: tmdb);

      final old = vm.loadInitial(query: '별빛');
      final latest = vm.loadInitial(query: '달빛');
      tmdb.pending['s:달빛:1']!.complete(page(1, [20]));
      await latest;
      tmdb.pending['s:별빛:1']!.complete(page(1, [10]));
      await old;

      expect(vm.movies.map((m) => m.id), [20]);
    });

    test('마지막 page 이후에는 hasMore가 false다', () async {
      final tmdb = FakeTmdb();
      final vm = PagedMoviesViewModel(tmdbApi: tmdb);
      final first = vm.loadInitial();
      tmdb.pending['d:null:1']!.complete(page(1, [1], totalPages: 1));
      await first;
      expect(vm.hasMore, isFalse);
    });

    test('total_pages가 500을 넘어도 500으로 제한한다', () async {
      final tmdb = FakeTmdb();
      final vm = PagedMoviesViewModel(tmdbApi: tmdb);
      final first = vm.loadInitial();
      tmdb.pending['d:null:1']!.complete(page(1, [1], totalPages: 900));
      await first;
      expect(vm.totalPages, 500);
    });
  });

  group('FavoriteDetailViewModel', () {
    FavoriteDetailViewModel create(FakeFavoriteApi api, SessionGuard guard) =>
        FavoriteDetailViewModel(
          movieId: 550,
          favoriteApi: api,
          sessionGuard: guard,
          accountId: 'a@example.com',
        );

    test('서버 성공 뒤에만 북마크가 바뀐다', () async {
      final api = FakeFavoriteApi();
      final guard = SessionGuard()..startSession('a@example.com');
      final vm = create(api, guard);
      await vm.load();
      expect(vm.isFavorite, isFalse);
      await vm.toggle();
      expect(vm.isFavorite, isTrue);
      await vm.toggle();
      expect(vm.isFavorite, isFalse);
    });

    test('FAVORITE409_1이면 서버 값으로 맞춘다', () async {
      final api = FakeFavoriteApi();
      final guard = SessionGuard()..startSession('a@example.com');
      final vm = create(api, guard);
      await vm.load();
      api
        ..serverValue = true
        ..addError = apiError('FAVORITE409_1', 409);
      await vm.toggle();
      expect(vm.isFavorite, isTrue);
      expect(vm.errorMessage, isNull);
    });

    test('네트워크 실패면 이전 상태를 유지한다', () async {
      final api = FakeFavoriteApi();
      final guard = SessionGuard()..startSession('a@example.com');
      final vm = create(api, guard);
      await vm.load();
      api.addError = Exception('network');
      await vm.toggle();
      expect(vm.isFavorite, isFalse);
      expect(vm.errorMessage, isNotNull);
    });
  });

  group('FavoritesViewModel', () {
    test('영화 정보 한 건 실패는 그 카드만 placeholder가 된다', () async {
      final api = FakeFavoriteApi()
        ..list = [
          FavoriteResponseDto(favoriteId: 1, movieId: 1, createdAt: DateTime(2026)),
          FavoriteResponseDto(favoriteId: 2, movieId: 2, createdAt: DateTime(2026)),
        ];
      final tmdb = FakeTmdb()..failingDetails.add(2);
      final guard = SessionGuard()..startSession('a@example.com');
      final vm = FavoritesViewModel(
        favoriteApi: api,
        tmdbApi: tmdb,
        sessionGuard: guard,
        accountId: 'a@example.com',
      );
      await vm.refresh();
      expect(vm.phase, LoadPhase.ready);
      expect(vm.items[0].hasMovie, isTrue);
      expect(vm.items[1].hasMovie, isFalse);

      tmdb.failingDetails.clear();
      await vm.retryMovie(2);
      expect(vm.items[1].hasMovie, isTrue);
    });

    test('세션이 바뀌면 이전 계정의 응답을 반영하지 않는다', () async {
      final api = FakeFavoriteApi()
        ..list = [
          FavoriteResponseDto(favoriteId: 1, movieId: 1, createdAt: DateTime(2026)),
        ];
      final guard = SessionGuard()..startSession('a@example.com');
      final vm = FavoritesViewModel(
        favoriteApi: api,
        tmdbApi: FakeTmdb(),
        sessionGuard: guard,
        accountId: 'a@example.com',
      );
      final future = vm.refresh();
      guard
        ..invalidate()
        ..startSession('b@example.com');
      await future;
      expect(vm.items, isEmpty);
    });
  });
}
