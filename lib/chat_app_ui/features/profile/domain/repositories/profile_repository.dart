import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(String userId);
  Future<ProfileEntity> editProfile(Map<String, dynamic> data);
  Future<List<ProfileEntity>> searchProfile(String query);
}
