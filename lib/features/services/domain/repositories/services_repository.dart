import '../models/service.dart';

abstract class ServicesRepository {
  Future<List<Service>> getServices();
}
