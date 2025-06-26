import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/screens/message_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/bloc/profile_event.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/bloc/profile_state.dart';
import 'package:chat_app/chat_app_ui/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:chat_app/chat_app_ui/features/profile/domain/usecases/edit_profile_usecase.dart';
import 'package:chat_app/chat_app_ui/features/profile/domain/usecases/search_profile_usecase.dart';
import 'package:chat_app/chat_app_ui/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:chat_app/chat_app_ui/features/contact/presentation/bloc/contact_event.dart';
import 'package:chat_app/chat_app_ui/features/contact/presentation/bloc/contact_state.dart';
import 'package:chat_app/chat_app_ui/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/get_contacts_use_case.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/add_contact_use_case.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/accept_contact_use_case.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/delete_contact_use_case.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:collection/collection.dart';
import 'package:chat_app/chat_app_ui/features/video_call/presentation/screens/video_call_screen.dart';

class ProfileScreen extends StatefulWidget {
  static Route route(String userId) =>
      MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId));

  static Route routeWithBloc(String userId, {ContactBloc? contactBloc}) {
    return MaterialPageRoute(
      builder: (context) {
        // Get token from AuthBloc
        final authState = context.read<AuthBloc>().state;
        String? token;
        if (authState is AuthSuccess) {
          token = authState.user.token;
        }

        // Try to get existing ContactBloc from context, or use provided one
        ContactBloc? existingContactBloc;
        try {
          existingContactBloc = context.read<ContactBloc>();
        } catch (e) {
          // ContactBloc not found in context, create new one with token
          if (token != null) {
            existingContactBloc = ContactBloc(
              getContactsUseCase: GetContactsUseCase(
                repository: ContactRepositoryImpl(
                  remoteDataSource: ContactRemoteDataSource(token: token),
                ),
              ),
              addContactUseCase: AddContactUseCase(
                repository: ContactRepositoryImpl(
                  remoteDataSource: ContactRemoteDataSource(token: token),
                ),
              ),
              acceptContactUseCase: AcceptContactUseCase(
                repository: ContactRepositoryImpl(
                  remoteDataSource: ContactRemoteDataSource(token: token),
                ),
              ),
              deleteContactUseCase: DeleteContactUseCase(
                repository: ContactRepositoryImpl(
                  remoteDataSource: ContactRemoteDataSource(token: token),
                ),
              ),
            );
          }
        }

        return MultiBlocProvider(
          providers: [
            if (existingContactBloc != null)
              BlocProvider.value(value: existingContactBloc),
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
          ],
          child: ProfileScreen(userId: userId),
        );
      },
    );
  }

  const ProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetProfileEvent(widget.userId));
    // Ensure ContactBloc has loaded contacts
    final contactBloc = context.read<ContactBloc>();
    if (contactBloc.state is! ContactLoaded) {
      contactBloc.add(LoadContacts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ContactError) {
            print('ContactError : ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Error',
                'Failed to update contact: ${state.message}',
                Icons.error,
                Colors.red,
              ),
            );
          } else if (state is ContactLoaded) {
            context.read<ProfileBloc>().add(GetProfileEvent(widget.userId));
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const CircularProgressIndicator(
                    color: AppColors.secondary,
                  );
                } else if (state is ProfileLoaded) {
                  final user = state.profile;
                  return Column(
                    children: [
                      Avatar.large(url: user.profilePic),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(user.username),
                      ),
                      _ButtonRow(isContacted: true, user: user),
                      SizedBox(height: 32),
                      _InfoContainer(user: user),
                      SizedBox(height: 32),
                      _MediaView(),
                    ],
                  );
                } else if (state is ProfileError) {
                  return Text('Error: ${state.message}');
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonRow extends StatefulWidget {
  const _ButtonRow({required this.isContacted, required this.user});
  final bool isContacted;
  final dynamic user;

  @override
  State<_ButtonRow> createState() => __ButtonRowState();
}

class __ButtonRowState extends State<_ButtonRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Navigate to chat screen
          IconBackGround(
            icon: CupertinoIcons.chat_bubble,
            onTap: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthSuccess) {
                final currentUserId = authState.user.id;
                final chatRemoteDataSource = ChatRemoteDataSourceImpl();
                ChatEntity? chat = await chatRemoteDataSource.getChatWithUser(
                  currentUserId,
                  widget.user.id,
                );
                if (chat != null) {
                  Navigator.of(context).push(MessageScreen.route(chat));
                } else {
                  try {
                    final newChat = await chatRemoteDataSource.createChat(
                      widget.user.id,
                    );
                    if (newChat != null) {
                      // Fetch chat with user to get full information
                      final fullChat = await chatRemoteDataSource
                          .getChatWithUser(currentUserId, widget.user.id);
                      if (fullChat != null) {
                        Navigator.of(
                          context,
                        ).push(MessageScreen.route(fullChat));
                      } else {
                        Navigator.of(
                          context,
                        ).push(MessageScreen.route(newChat));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create chat.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create chat: $e')),
                    );
                  }
                }
              }
            },
            circularBorder: true,
          ),
          // Navigate to video call screen
          Opacity(
            opacity: widget.user.contactStatus == 'accepted' ? 1.0 : 0.4,
            child: IconBackGround(
              icon: CupertinoIcons.video_camera,
              onTap:
                  widget.user.contactStatus == 'accepted'
                      ? () async {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthSuccess) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => VideoCallScreen(
                                    roomName: widget.user.id,
                                    identity: authState.user.id,
                                    cameraOff: false,
                                  ),
                            ),
                          );
                        }
                      }
                      : null,
              size: 24,
              circularBorder: true,
            ),
          ),
          // Navigate to audio call screen
          Opacity(
            opacity: widget.user.contactStatus == 'accepted' ? 1.0 : 0.4,
            child: IconBackGround(
              icon: CupertinoIcons.phone,
              onTap:
                  widget.user.contactStatus == 'accepted'
                      ? () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthSuccess) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => VideoCallScreen(
                                    roomName: widget.user.id,
                                    identity: authState.user.id,
                                    cameraOff: true,
                                  ),
                            ),
                          );
                        }
                      }
                      : null,
              circularBorder: true,
            ),
          ),
          // Add or remove contact
          IconBackGround(
            icon:
                widget.user.contactStatus == 'none'
                    ? Icons.person_add_alt_1_outlined
                    : widget.user.contactStatus == 'pending'
                    ? Icons.hourglass_top
                    : Icons.person_remove_outlined,
            circularBorder: true,
            onTap:
                widget.user.contactStatus == 'pending'
                    ? null
                    : () {
                      if (widget.user.contactStatus == 'none') {
                        context.read<ContactBloc>().add(
                          AddContact(widget.user.email),
                        );
                      } else if (widget.user.contactStatus == 'accepted') {
                        final contactState = context.read<ContactBloc>().state;
                        if (contactState is! ContactLoaded) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Contacts not loaded yet!')),
                          );
                          return;
                        }
                        debugPrint(
                          'ProfileScreen: widget.user.id=${widget.user.id}',
                        );
                        for (var c in contactState.contacts) {
                          debugPrint(
                            'Contact: userId=${c.userId}, contactId=${c.contactId}, email=${c.email}',
                          );
                        }
                        final contact = contactState.contacts.firstWhereOrNull(
                          (c) =>
                              c.userId == widget.user.id ||
                              c.contactId == widget.user.id ||
                              c.email == widget.user.email,
                        );
                        if (contact != null) {
                          context.read<ContactBloc>().add(
                            DeleteContact(contact.contactId),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cannot delete contact: missing contactId',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
          ),
        ],
      ),
    );
  }
}

class _InfoContainer extends StatelessWidget {
  const _InfoContainer({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.circularIcon,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name', style: TextStyle(color: AppColors.textFaded)),
              Text(user.username),
            ],
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gender', style: TextStyle(color: AppColors.textFaded)),
              Text(
                user.gender ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email', style: TextStyle(color: AppColors.textFaded)),
              Text(user.email),
            ],
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone Number',
                style: TextStyle(color: AppColors.textFaded),
              ),
              Text(user.phoneNumber ?? ''),
            ],
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Status',
                style: TextStyle(color: AppColors.textFaded),
              ),
              Text(user.contactStatus ?? ''),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaView extends StatelessWidget {
  const _MediaView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stories Shared',
              style: TextStyle(color: AppColors.textFaded),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 0),
              child: Text(
                'View All',
                style: TextStyle(color: AppColors.secondary, fontSize: 14),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _MediaList(),
      ],
    );
  }
}

class _MediaList extends StatefulWidget {
  const _MediaList();

  @override
  State<_MediaList> createState() => __MediaListState();
}

class __MediaListState extends State<_MediaList> {
  final List<Map<String, String>> mediaItems = [
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/200/300?random=1',
      'caption': 'Image 1',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/100/300?random=1',
      'caption': 'Image 2',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/300/300?random=1',
      'caption': 'Image 3',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/150/300?random=1',
      'caption': 'Image 3',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/250/300?random=1',
      'caption': 'Image 3',
    },
    {
      'type': 'image',
      'mediaUrl': 'https://picsum.photos/50/300?random=1',
      'caption': 'Image 3',
    },
  ];

  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, AudioPlayer> _audioPlayers = {};

  @override
  void initState() {
    super.initState();
    _initializeMediaControllers();
  }

  void _initializeMediaControllers() {
    for (int i = 0; i < mediaItems.length; i++) {
      if (mediaItems[i]['type'] == 'video') {
        _videoControllers[i] = VideoPlayerController.networkUrl(
            Uri.parse(mediaItems[i]['mediaUrl']!),
          )
          ..initialize().then((_) {
            setState(() {});
          });
      } else if (mediaItems[i]['type'] == 'audio') {
        _audioPlayers[i] = AudioPlayer();
      }
    }
  }

  @override
  void dispose() {
    _videoControllers.forEach((_, controller) => controller.dispose());
    _audioPlayers.forEach((_, player) => player.dispose());
    super.dispose();
  }

  Widget _buildMediaItem(int index) {
    final mediaType = mediaItems[index]['type'];

    switch (mediaType) {
      case 'image':
        return Container(
          width: 90,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: CachedNetworkImageProvider(mediaItems[index]['mediaUrl']!),
              fit: BoxFit.cover,
            ),
          ),
        );

      case 'video':
        if (!_videoControllers[index]!.value.isInitialized) {
          return Container(
            width: 90,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          );
        }
        return Column(
          children: [
            Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayer(_videoControllers[index]!),
              ),
            ),
          ],
        );

      case 'audio':
        return Column(
          children: [
            Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: Center(child: Icon(Icons.audiotrack, size: 40)),
            ),
          ],
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = mediaItems.length > 3 ? 2 : mediaItems.length;
    final hasMoreItems = mediaItems.length > 3;

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (hasMoreItems && index == displayCount) {
            return Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  opacity: 0.3,
                  image: NetworkImage(mediaItems[index]['mediaUrl']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  '+${mediaItems.length - 2}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          return InkWell(onTap: () {}, child: _buildMediaItem(index));
        },
        separatorBuilder: (context, index) => SizedBox(width: 12),
        itemCount: displayCount + (hasMoreItems ? 1 : 0),
      ),
    );
  }
}
