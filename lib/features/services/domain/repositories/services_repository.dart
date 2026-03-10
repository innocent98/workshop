import '../models/service.dart';
import '../models/service_category.dart';

abstract class ServicesRepository {
  Future<List<Service>> getServices({
    String? categoryId,
    bool includeUncategorized = false,
  });
  Future<List<ServiceCategory>> getServiceCategories();
}
