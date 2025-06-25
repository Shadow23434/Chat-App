import '../repositories/contact_repository.dart';

class AcceptContactUseCase {
  final ContactRepository repository;
  AcceptContactUseCase({required this.repository});

  Future<void> call(String contactId) async {
    await repository.acceptContact(contactId);
  }
}
