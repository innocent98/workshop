import '../../../client_home/domain/models/artisan.dart';
import '../../data/models/search_request.dart';

abstract class SearchRepository {
  Future<List<Artisan>> searchArtisans(SearchArtisansRequest request);
}
