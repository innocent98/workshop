import 'package:logger/logger.dart';
import '../../../client_home/domain/models/artisan.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';
import '../models/search_request.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;
  final Logger _logger = Logger();

  SearchRepositoryImpl({
    SearchRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? SearchRemoteDataSource();

  @override
  Future<List<Artisan>> searchArtisans(SearchArtisansRequest request) async {
    try {
      final response = await _remoteDataSource.searchArtisans(request);
      
      // Map ArtisanSearchModel to Artisan domain model
      return response.artisans.map((model) {
        return Artisan.fromSearchModel(model);
      }).toList();
    } catch (e) {
      _logger.e('Error in SearchRepository: $e');
      rethrow;
    }
  }
}
