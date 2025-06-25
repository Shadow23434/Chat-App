import 'package:chat_app/chat_app_ui/features/contact/presentation/screens/contact_screen.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/screens/search_profile_screen.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/screens/create_story_screen.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:chat_app/chat_app_ui/pages/pages.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:chat_app/chat_app_ui/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:chat_app/chat_app_ui/features/contact/presentation/bloc/contact_event.dart';
import 'package:chat_app/chat_app_ui/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/get_contacts_use_case.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/add_contact_use_case.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/accept_contact_use_case.dart';
import 'package:chat_app/chat_app_ui/features/contact/domain/usecases/delete_contact_use_case.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/bloc/story_bloc.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/bloc/story_event.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/get_stories_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/create_story_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/like_story_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/unlike_story_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/delete_story_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/usecases/get_own_stories_usecase.dart';
import 'package:chat_app/chat_app_ui/features/story/data/repositories/story_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/story/data/datasources/story_remote_data_source.dart';

class HomeScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => HomeScreen());
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int selectedIndex = 0;
  String title = 'Messages';

  final pageTitles = const ['Messages', 'Notifications', 'Calls', 'Contacts'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      selectedIndex = index;
      title = pageTitles[index];
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
      title = pageTitles[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get token from AuthBloc
    final authState = context.watch<AuthBloc>().state;
    String? token;
    if (authState is AuthSuccess) {
      token = authState.user.token;
    }

    if (token == null) {
      // Nếu chưa đăng nhập, show loading
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ChatBloc(
                getChatsUseCase: GetChatsUseCase(
                  repository: ChatRepositoryImpl(
                    remoteDataSource: ChatRemoteDataSourceImpl(),
                  ),
                ),
              ),
        ),
        BlocProvider(
          key: ValueKey(
            token,
          ), // Đảm bảo ContactBloc được tạo lại khi token đổi
          create:
              (_) => ContactBloc(
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
              )..add(LoadContacts()),
        ),
        BlocProvider(
          create:
              (context) => StoryBloc(
                getStoriesUseCase: GetStoriesUseCase(
                  StoryRepositoryImpl(
                    remoteDataSource: StoryRemoteDataSource(),
                  ),
                ),
                getOwnStoriesUseCase: GetOwnStoriesUseCase(
                  repository: StoryRepositoryImpl(
                    remoteDataSource: StoryRemoteDataSource(),
                  ),
                ),
                createStoryUseCase: CreateStoryUseCase(
                  StoryRepositoryImpl(
                    remoteDataSource: StoryRemoteDataSource(),
                  ),
                ),
                likeStoryUseCase: LikeStoryUseCase(
                  StoryRepositoryImpl(
                    remoteDataSource: StoryRemoteDataSource(),
                  ),
                ),
                unlikeStoryUseCase: UnlikeStoryUseCase(
                  StoryRepositoryImpl(
                    remoteDataSource: StoryRemoteDataSource(),
                  ),
                ),
                deleteStoryUseCase: DeleteStoryUseCase(
                  StoryRepositoryImpl(
                    remoteDataSource: StoryRemoteDataSource(),
                  ),
                ),
              )..add(GetStories()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          title: Center(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          leadingWidth: 54,
          leading: Align(
            alignment: Alignment.centerRight,
            child: IconBackGround(
              icon: Icons.search,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchProfileScreen(),
                  ),
                );
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String avatarUrl = defaultAvatarUrl;
                  if (state is AuthSuccess) {
                    avatarUrl = state.user.profilePic ?? defaultAvatarUrl;
                  }
                  return Avatar.small(
                    url: avatarUrl,
                    onTap: () {
                      Navigator.of(context).push(OwnProfileScreen.route);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            ChatScreen(),
            NotificationsPage(),
            CallScreen(),
            ContactScreen(),
          ],
        ),
        bottomNavigationBar: _CustomBottomNavigationBar(
          onItemSelected: _onNavigationItemSelected,
          selectedIndex: selectedIndex,
        ),
      ),
    );
  }
}

class _CustomBottomNavigationBar extends StatelessWidget {
  const _CustomBottomNavigationBar({
    required this.onItemSelected,
    required this.selectedIndex,
  });

  final ValueChanged<int> onItemSelected;
  final int selectedIndex;

  void handleItemSelected(int index) {
    onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavigationBarItem(
                index: 0,
                label: 'Messages',
                icon: CupertinoIcons.bubble_left_bubble_right_fill,
                isSelected: (selectedIndex == 0),
                onTap: handleItemSelected,
              ),
              _NavigationBarItem(
                index: 1,
                label: 'Notifications',
                icon: CupertinoIcons.bell_solid,
                isSelected: (selectedIndex == 1),
                onTap: handleItemSelected,
              ),
              GlowingActionButton(
                color: AppColors.secondary,
                icon: CupertinoIcons.add,
                onPressed: () {
                  Navigator.of(context).push(CreateStoryScreen.route());
                },
              ),
              _NavigationBarItem(
                index: 2,
                label: 'Calls',
                icon: CupertinoIcons.phone_fill,
                isSelected: (selectedIndex == 2),
                onTap: handleItemSelected,
              ),
              _NavigationBarItem(
                index: 3,
                label: 'Contacts',
                icon: CupertinoIcons.person_2_fill,
                isSelected: (selectedIndex == 3),
                onTap: handleItemSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem({
    required this.index,
    required this.label,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  final int index;
  final String label;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(index);
      },
      child: SizedBox(
        height: 60,
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.secondary : null,
            ),
          ],
        ),
      ),
    );
  }
}
