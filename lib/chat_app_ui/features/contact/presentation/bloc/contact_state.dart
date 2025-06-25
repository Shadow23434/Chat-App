import 'package:equatable/equatable.dart';
import '../../domain/entities/contact_entity.dart';

abstract class ContactState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactLoaded extends ContactState {
  final List<ContactEntity> contacts;
  ContactLoaded(this.contacts);
  @override
  List<Object?> get props => [contacts];
}

class ContactError extends ContactState {
  final String message;
  ContactError(this.message);
  @override
  List<Object?> get props => [message];
}

// State mới: báo action thành công
class ContactActionSuccess extends ContactState {}
