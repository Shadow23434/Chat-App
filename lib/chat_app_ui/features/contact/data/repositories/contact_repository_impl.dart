import '../datasources/contact_remote_data_source.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../domain/entities/contact_entity.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ContactEntity>> getContacts() async {
    final models = await remoteDataSource.getContacts();
    return models
        .map(
          (m) => ContactEntity(
            contactId: m.contactId,
            userId: m.userId,
            username: m.username,
            profilePic: m.profilePic,
            email: m.email,
            status: m.status,
          ),
        )
        .toList();
  }

  @override
  Future<void> addContact(String email) async {
    await remoteDataSource.addContact(email);
  }

  @override
  Future<void> acceptContact(String contactId) async {
    await remoteDataSource.acceptContact(contactId);
  }

  @override
  Future<void> deleteContact(String contactId) async {
    await remoteDataSource.deleteContact(contactId);
  }
}
