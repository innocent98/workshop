import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/service.dart';
import '../../domain/models/service_category.dart';
import '../../data/repositories/services_repository_impl.dart';

final servicesRepositoryProvider = Provider((ref) {
  return ServicesRepositoryImpl();
});

final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final repository = ref.watch(servicesRepositoryProvider);
  return repository.getServices();
});

final serviceCategoriesProvider = FutureProvider<List<ServiceCategory>>((
  ref,
) async {
  final repository = ref.watch(servicesRepositoryProvider);
  return repository.getServiceCategories();
});

final servicesByCategoryProvider = FutureProvider.family<List<Service>, String>(
  (ref, categoryId) async {
    final repository = ref.watch(servicesRepositoryProvider);
    return repository.getServices(categoryId: categoryId);
  },
);
