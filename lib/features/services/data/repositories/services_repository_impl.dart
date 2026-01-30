import '../../domain/models/service.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource _remoteDataSource;

  ServicesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Service>> fetchServices() async {
    final models = await _remoteDataSource.fetchServices();
    return models.map((model) => model.toEntity()).toList();
  }
}
