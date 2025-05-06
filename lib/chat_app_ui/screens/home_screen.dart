import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:chat_app/chat_app_ui/pages/pages.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => HomeScreen());
  HomeScreen({super.key});

  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Messages');

  final pages = const [
    MessagesPage(),
    NotificationsPage(),
    CallsPage(),
    ContactsPage(),
  ];

  final pageTitles = const ['Messages', 'Notifications', 'Calls', 'Contacts'];

  void _onNavigationItemSelected(index) {
    title.value = pageTitles[index];
    pageIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: ValueListenableBuilder(
          valueListenable: title,
          builder: (BuildContext context, String value, _) {
            return Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackGround(
            icon: Icons.search,
            onTap: () {
              // print('Searching!');
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Avatar.small(
              url: defaultAvatarUrl,
              onTap: () {
                Navigator.of(context).push(OwnProfileScreen.route);
              },
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (BuildContext context, int value, _) {
          return pages[value];
        },
      ),
      bottomNavigationBar: __BottomNavigationBar(
        onItemSelected: _onNavigationItemSelected,
      ),
    );
  }
}

class __BottomNavigationBar extends StatefulWidget {
  const __BottomNavigationBar({required this.onItemSelected});

  final ValueChanged<int> onItemSelected;

  @override
  State<__BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<__BottomNavigationBar> {
  var selectedIndex = 0;

  void handleItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onItemSelected(index);
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
                  // showDialog(
                  //   context: context,
                  //   builder:
                  //       (BuildContext context) => const Dialog(
                  //         child: AspectRatio(
                  //           aspectRatio: 8 / 7,
                  //           child: ContactsPage(),
                  //         ),
                  //       ),
                  // );
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
            // SizedBox(height: 8),
            // Text(
            //   label,
            //   style:
            //       isSelected
            //           ? const TextStyle(
            //             fontSize: 11,
            //             fontWeight: FontWeight.bold,
            //             color: AppColors.secondary,
            //           )
            //           : const TextStyle(fontSize: 11),
            // ),
          ],
        ),
      ),
    );
  }
}
