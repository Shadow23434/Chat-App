import '../entities/contact_entity.dart';

abstract class ContactRepository {
  Future<List<ContactEntity>> getContacts();
  Future<void> addContact(String email);
  Future<void> acceptContact(String contactId);
  Future<void> deleteContact(String contactId);
}
