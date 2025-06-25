import 'package:chat_app/chat_app_ui/features/profile/presentation/screens/profile_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_event.dart';
import '../bloc/contact_state.dart';

class AcceptContactDialog extends StatelessWidget {
  const AcceptContactDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        if (state is ContactError) {
          return AlertDialog(
            title: Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(state.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        }
        final pendingContacts =
            (state is ContactLoaded)
                ? state.contacts.where((c) => c.status == 'pending').toList()
                : [];
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.hourglass_top),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pending Contacts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            child:
                pendingContacts.isNotEmpty
                    ? ListView.builder(
                      itemCount: pendingContacts.length,
                      itemBuilder: (context, index) {
                        final contact = pendingContacts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              // Avatar
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    ProfileScreen.routeWithBloc(
                                      contact.userId,
                                      contactBloc: context.read<ContactBloc>(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      contact.profilePic != null &&
                                              contact.profilePic!.isNotEmpty
                                          ? NetworkImage(contact.profilePic!)
                                          : null,
                                  child:
                                      (contact.profilePic == null ||
                                              contact.profilePic!.isEmpty)
                                          ? Icon(
                                            Icons.person,
                                            color: AppColors.secondary,
                                            size: 20,
                                          )
                                          : null,
                                ),
                              ),
                              SizedBox(width: 12),
                              // Name
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      ProfileScreen.routeWithBloc(
                                        contact.userId,
                                        contactBloc:
                                            context.read<ContactBloc>(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    contact.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Accept Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  context.read<ContactBloc>().add(
                                    AcceptContact(contact.contactId),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Accept',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                    : Center(
                      child: Text(
                        'No pending contacts',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
          ],
        );
      },
    );
  }
}
