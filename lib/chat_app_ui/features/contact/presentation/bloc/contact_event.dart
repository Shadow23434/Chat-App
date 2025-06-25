import 'package:equatable/equatable.dart';

abstract class ContactEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadContacts extends ContactEvent {}

class AddContact extends ContactEvent {
  final String email;
  AddContact(this.email);
  @override
  List<Object?> get props => [email];
}

class AcceptContact extends ContactEvent {
  final String contactId;
  AcceptContact(this.contactId);
  @override
  List<Object?> get props => [contactId];
}

class DeleteContact extends ContactEvent {
  final String contactId;
  DeleteContact(this.contactId);
  @override
  List<Object?> get props => [contactId];
}
