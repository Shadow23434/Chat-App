import '../repositories/contact_repository.dart';
import '../entities/contact_entity.dart';

class GetContactsUseCase {
  final ContactRepository repository;
  GetContactsUseCase({required this.repository});

  Future<List<ContactEntity>> call() async {
    return await repository.getContacts();
  }
}
