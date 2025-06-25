import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileModel> getProfile(String userId) async {
    return await remoteDataSource.getProfile(userId);
  }

  @override
  Future<ProfileModel> editProfile(Map<String, dynamic> data) async {
    return await remoteDataSource.editProfile(data);
  }

  @override
  Future<List<ProfileModel>> searchProfile(String query) async {
    return await remoteDataSource.searchProfile(query);
  }
}
