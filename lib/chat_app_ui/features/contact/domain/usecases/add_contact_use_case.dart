import '../repositories/contact_repository.dart';

class AddContactUseCase {
  final ContactRepository repository;
  AddContactUseCase({required this.repository});

  Future<void> call(String email) async {
    await repository.addContact(email);
  }
}
