import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/profile_remote_datasource.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSource();
});
