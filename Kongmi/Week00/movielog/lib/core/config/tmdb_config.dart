import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class TmdbConfig {
  static String get accessToken => dotenv.env['TMDB_ACCESS_TOKEN'] ?? '';
}
