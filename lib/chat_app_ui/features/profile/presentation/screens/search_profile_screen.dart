import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/accept_contact_use_case.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/add_contact_use_case.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/delete_contact_use_case.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/get_contacts_use_case.dart';
import 'package:chat_app/chat_app_ui/widgets/default_app_bar.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/edit_profile_usecase.dart';
import '../../domain/usecases/search_profile_usecase.dart';
import 'profile_screen.dart';
import 'dart:async';
import 'package:chat_app/chat_app_ui/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:chat_app/chat_app_ui/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/contact/data/repositories/contact_repository_impl.dart';

class SearchProfileScreen extends StatelessWidget {
  const SearchProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    Timer? debounce;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => ProfileBloc(
                getProfileUseCase: GetProfileUseCase(
                  repository: ProfileRepositoryImpl(
                    remoteDataSource: ProfileRemoteDataSource(),
                  ),
                ),
                editProfileUseCase: EditProfileUseCase(
                  repository: ProfileRepositoryImpl(
                    remoteDataSource: ProfileRemoteDataSource(),
                  ),
                ),
                searchProfileUseCase: SearchProfileUseCase(
                  repository: ProfileRepositoryImpl(
                    remoteDataSource: ProfileRemoteDataSource(),
                  ),
                ),
              ),
        ),
        BlocProvider(
          create:
              (_) => ContactBloc(
                addContactUseCase: AddContactUseCase(
                  repository: ContactRepositoryImpl(
                    remoteDataSource: ContactRemoteDataSource(),
                  ),
                ),
                getContactsUseCase: GetContactsUseCase(
                  repository: ContactRepositoryImpl(
                    remoteDataSource: ContactRemoteDataSource(),
                  ),
                ),
                acceptContactUseCase: AcceptContactUseCase(
                  repository: ContactRepositoryImpl(
                    remoteDataSource: ContactRemoteDataSource(),
                  ),
                ),
                deleteContactUseCase: DeleteContactUseCase(
                  repository: ContactRepositoryImpl(
                    remoteDataSource: ContactRemoteDataSource(),
                  ),
                ),
              ),
        ),
      ],
      child: Builder(
        builder:
            (context) => Scaffold(
              appBar: DefaultAppBar(),
              body: BlocListener<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileError) {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: 'Enter username or email',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon:
                                  controller.text.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          controller.clear();
                                          context.read<ProfileBloc>().add(
                                            SearchProfileEvent(''),
                                          );
                                          setState(() {});
                                        },
                                      )
                                      : null,
                            ),
                            onChanged: (query) {
                              if (debounce?.isActive ?? false) {
                                debounce!.cancel();
                              }
                              debounce = Timer(
                                const Duration(milliseconds: 400),
                                () {
                                  if (query.trim().isNotEmpty) {
                                    context.read<ProfileBloc>().add(
                                      SearchProfileEvent(query),
                                    );
                                  } else {
                                    context.read<ProfileBloc>().add(
                                      SearchProfileEvent(''),
                                    );
                                  }
                                  setState(() {});
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          if (state is ProfileLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                            );
                          } else if (state is ProfileListLoaded) {
                            if (state.profiles.isEmpty) {
                              return const Center(
                                child: Text('No results found.'),
                              );
                            }
                            return ListView.builder(
                              itemCount: state.profiles.length,
                              itemBuilder: (context, i) {
                                final user = state.profiles[i];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        user.profilePic != null &&
                                                user.profilePic!.isNotEmpty
                                            ? NetworkImage(user.profilePic!)
                                            : null,
                                    child:
                                        (user.profilePic == null ||
                                                user.profilePic!.isEmpty)
                                            ? const Icon(Icons.person)
                                            : null,
                                  ),
                                  title: Text(user.username),
                                  subtitle: Text(user.email),
                                  onTap: () {
                                    // Pass the existing ContactBloc to ProfileScreen
                                    Navigator.of(context).push(
                                      ProfileScreen.routeWithBloc(
                                        user.id,
                                        contactBloc:
                                            context.read<ContactBloc>(),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else if (state is ProfileError) {
                            return const SizedBox();
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
