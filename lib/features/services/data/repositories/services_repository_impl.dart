import 'package:logger/logger.dart';
import '../../domain/models/service.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource _remoteDataSource;
  final Logger _logger = Logger();

  ServicesRepositoryImpl({
    ServicesRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ServicesRemoteDataSource();

  @override
  Future<List<Service>> getServices() async {
    try {
      final serviceModels = await _remoteDataSource.fetchServices();
      
      // Map ServiceModel to Service domain model
      return serviceModels.map((model) {
        return Service(
          id: model.id,
          name: model.name,
          description: model.description,
          imageUrl: model.imageUrl,
        );
      }).toList();
    } catch (e) {
      _logger.e('Error in ServicesRepository: $e');
      rethrow;
    }
  }
}
