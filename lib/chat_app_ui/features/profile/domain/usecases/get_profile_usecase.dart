import '../repositories/profile_repository.dart';
import '../entities/profile_entity.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase({required this.repository});

  Future<ProfileEntity> call(String userId) {
    return repository.getProfile(userId);
  }
}
