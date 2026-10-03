import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String selectedGenre = '전체';

  final List<String> genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredMovies = selectedGenre == '전체'
        ? mockMovies
        : mockMovies
            .where((movie) => movie.genre.contains(selectedGenre))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('영화', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: genres.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = selectedGenre == genre;
                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  selectedColor: colors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => selectedGenre = genre),
                );
              },
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMovies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) =>
                  MovieCard(movie: filteredMovies[index]),
            ),
          ),
        ],
      ),
    );
  }
}