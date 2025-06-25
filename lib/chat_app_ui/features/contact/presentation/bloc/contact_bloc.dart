import 'package:flutter_bloc/flutter_bloc.dart';
import 'contact_event.dart';
import 'contact_state.dart';
import '../../domain/usecases/get_contacts_use_case.dart';
import '../../domain/usecases/add_contact_use_case.dart';
import '../../domain/usecases/accept_contact_use_case.dart';
import '../../domain/usecases/delete_contact_use_case.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final GetContactsUseCase getContactsUseCase;
  final AddContactUseCase addContactUseCase;
  final AcceptContactUseCase acceptContactUseCase;
  final DeleteContactUseCase deleteContactUseCase;

  ContactBloc({
    required this.getContactsUseCase,
    required this.addContactUseCase,
    required this.acceptContactUseCase,
    required this.deleteContactUseCase,
  }) : super(ContactInitial()) {
    on<LoadContacts>((event, emit) async {
      emit(ContactLoading());
      try {
        final contacts = await getContactsUseCase();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });
    on<AddContact>((event, emit) async {
      emit(ContactLoading());
      try {
        await addContactUseCase(event.email);
        emit(ContactActionSuccess());
        add(LoadContacts());
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });
    on<AcceptContact>((event, emit) async {
      emit(ContactLoading());
      try {
        await acceptContactUseCase(event.contactId);
        emit(ContactActionSuccess());
        add(LoadContacts());
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });
    on<DeleteContact>((event, emit) async {
      emit(ContactLoading());
      try {
        await deleteContactUseCase(event.contactId);
        emit(ContactActionSuccess());
        add(LoadContacts());
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });
  }
}
