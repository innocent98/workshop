import 'package:logger/logger.dart';
import '../../domain/models/service.dart';
import '../../domain/models/service_category.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource _remoteDataSource;
  final Logger _logger = Logger();

  ServicesRepositoryImpl({ServicesRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ServicesRemoteDataSource();

  @override
  Future<List<Service>> getServices({
    String? categoryId,
    bool includeUncategorized = false,
  }) async {
    try {
      final serviceModels = await _remoteDataSource.fetchServices(
        categoryId: categoryId,
        includeUncategorized: includeUncategorized,
      );

      // Map ServiceModel to Service domain model
      return serviceModels.map((model) {
        return Service(
          id: model.id,
          name: model.name,
          description: model.description,
          imageUrl: model.imageUrl,
          categoryId: model.categoryId,
          categoryName: model.categoryName,
        );
      }).toList();
    } catch (e) {
      _logger.e('Error in ServicesRepository: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      final models = await _remoteDataSource.fetchServiceCategories();
      return models
          .map(
            (model) => ServiceCategory(
              id: model.id,
              name: model.name,
              description: model.description,
              icon: model.icon,
              isActive: model.isActive,
              displayOrder: model.displayOrder,
            ),
          )
          .toList();
    } catch (e) {
      _logger.e('Error fetching service categories in repository: $e');
      rethrow;
    }
  }
}
