import '../repositories/profile_repository.dart';
import '../entities/profile_entity.dart';

class SearchProfileUseCase {
  final ProfileRepository repository;
  SearchProfileUseCase({required this.repository});

  Future<List<ProfileEntity>> call(String query) {
    return repository.searchProfile(query);
  }
}
