import '../repositories/profile_repository.dart';
import '../entities/profile_entity.dart';

class EditProfileUseCase {
  final ProfileRepository repository;
  EditProfileUseCase({required this.repository});

  Future<ProfileEntity> call(Map<String, dynamic> data) {
    return repository.editProfile(data);
  }
}
