import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/services_remote_datasource.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/models/service.dart';
import '../../domain/repositories/services_repository.dart';

final servicesRemoteDataSourceProvider = Provider<ServicesRemoteDataSource>((ref) {
  return ServicesRemoteDataSource();
});

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  final remoteDataSource = ref.read(servicesRemoteDataSourceProvider);
  return ServicesRepositoryImpl(remoteDataSource);
});

final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final repository = ref.read(servicesRepositoryProvider);
  return await repository.fetchServices();
});
