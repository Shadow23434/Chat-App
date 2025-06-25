import '../repositories/contact_repository.dart';

class DeleteContactUseCase {
  final ContactRepository repository;
  DeleteContactUseCase({required this.repository});

  Future<void> call(String contactId) async {
    await repository.deleteContact(contactId);
  }
}
