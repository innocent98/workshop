import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/client_profile_remote_datasource.dart';
import '../../domain/models/client_profile.dart';
import '../../domain/repositories/client_profile_repository.dart';
import '../../data/repositories/client_profile_repository_impl.dart';

final clientProfileRepositoryProvider = Provider<ClientProfileRepository>((
  ref,
) {
  return ClientProfileRepositoryImpl();
});

final clientProfileRemoteDataSourceProvider =
    Provider<ClientProfileRemoteDataSource>((ref) {
      return ClientProfileRemoteDataSource();
    });

final clientProfileProvider = FutureProvider<ClientProfile>((ref) async {
  final repository = ref.watch(clientProfileRepositoryProvider);
  return await repository.getMyProfile();
});
