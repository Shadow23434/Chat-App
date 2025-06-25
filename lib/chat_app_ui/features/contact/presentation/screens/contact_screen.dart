import 'package:chat_app/chat_app_ui/features/profile/presentation/screens/profile_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_state.dart';
import '../bloc/contact_event.dart';
import 'accept_contact_dialog.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ContactActionSuccess) {
            context.read<ContactBloc>().add(LoadContacts());
          }
        },
        child: BlocBuilder<ContactBloc, ContactState>(
          builder: (context, state) {
            if (state is ContactLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              );
            } else if (state is ContactLoaded) {
              final acceptedContacts =
                  state.contacts.where((c) => c.status == 'accepted').toList();
              if (acceptedContacts.isEmpty) {
                return Center(child: Text('No contacts found.'));
              }
              return RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: () async {
                  context.read<ContactBloc>().add(LoadContacts());
                },
                child: ListView.builder(
                  itemCount: acceptedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = acceptedContacts[index];
                    return ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            ProfileScreen.routeWithBloc(
                              contact.userId,
                              contactBloc: context.read<ContactBloc>(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage:
                              contact.profilePic != null &&
                                      contact.profilePic!.isNotEmpty
                                  ? NetworkImage(contact.profilePic!)
                                  : null,
                          child:
                              (contact.profilePic == null ||
                                      contact.profilePic!.isEmpty)
                                  ? Icon(Icons.person)
                                  : null,
                        ),
                      ),
                      title: Text(contact.username),
                      subtitle: Text(contact.email),
                    );
                  },
                ),
              );
            } else if (state is ContactError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Container();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (dialogContext) => BlocProvider.value(
                  value: context.read<ContactBloc>(),
                  child: AcceptContactDialog(),
                ),
          );
        },
        child: Icon(Icons.person_add),
      ),
    );
  }
}
