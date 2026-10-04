import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import '../storage/genre_preference.dart';
import '../widgets/genre_chip_bar.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';

enum _DebugScenario { success, empty, failure, failThenRetrySuccess }

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러', '로맨스', '코미디'];

  final _movieService = const FakeMovieService();
  final _genrePreference = GenrePreference();

  late Future<List<Movie>> _moviesFuture;
  String _selectedGenre = '전체';

  _DebugScenario _scenario = _DebugScenario.success;
  int _loadCount = 0;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _fetchMovies();
    _restoreGenre();
  }

  Future<List<Movie>> _fetchMovies() {
    _loadCount++;
    final mode = switch (_scenario) {
      _DebugScenario.success => MovieLoadMode.success,
      _DebugScenario.empty => MovieLoadMode.empty,
      _DebugScenario.failure => MovieLoadMode.failure,
      _DebugScenario.failThenRetrySuccess =>
        _loadCount == 1 ? MovieLoadMode.failure : MovieLoadMode.success,
    };
    // TODO(5주차 유저별 평점 조회 API): FakeMovieService를 실제 API Service로 교체
    return _movieService.fetchMovies(mode: mode);
  }

  Future<void> _restoreGenre() async {
    final genre = await _genrePreference.read();
    if (!mounted) return;
    setState(() {
      _selectedGenre = _genres.contains(genre) ? genre : '전체';
    });
  }

  Future<void> _selectGenre(String genre) async {
    setState(() => _selectedGenre = genre);
    await _genrePreference.save(genre);
  }

  void _retry() {
    setState(() {
      _moviesFuture = _fetchMovies();
    });
  }

  void _changeScenario(_DebugScenario scenario) {
    setState(() {
      _scenario = scenario;
      _loadCount = 0;
      _moviesFuture = _fetchMovies();
    });
  }

  List<Movie> _filterByGenre(List<Movie> movies) {
    if (_selectedGenre == '전체') return movies;
    return movies
        .where((movie) => movie.genre.split('/').contains(_selectedGenre))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '영화',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          if (kDebugMode)
            PopupMenuButton<_DebugScenario>(
              icon: const Icon(Icons.bug_report_outlined),
              onSelected: _changeScenario,
              itemBuilder: (context) => const [
                PopupMenuItem(value: _DebugScenario.success, child: Text('성공')),
                PopupMenuItem(value: _DebugScenario.empty, child: Text('빈 목록')),
                PopupMenuItem(value: _DebugScenario.failure, child: Text('실패')),
                PopupMenuItem(
                  value: _DebugScenario.failThenRetrySuccess,
                  child: Text('실패 → 재시도 성공'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          GenreChipBar(
            genres: _genres,
            selectedGenre: _selectedGenre,
            onSelected: _selectGenre,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const MovieListLoading();
                }

                if (snapshot.hasError) {
                  return MovieListError(onRetry: _retry);
                }

                final movies =
                    _filterByGenre(snapshot.data ?? const <Movie>[]);

                if (movies.isEmpty) {
                  return const MovieListEmpty();
                }

                return MovieGrid(movies: movies);
              },
            ),
          ),
        ],
      ),
    );
  }
}