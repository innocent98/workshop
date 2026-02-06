import '../models/client_profile.dart';

abstract class ClientProfileRepository {
  Future<ClientProfile> getMyProfile();
}
