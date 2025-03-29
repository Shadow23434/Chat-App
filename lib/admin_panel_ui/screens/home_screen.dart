import 'package:chat_app/admin_panel_ui/pages/pages.dart';
import 'package:chat_app/admin_panel_ui/screens/screens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/chat_app_ui/theme.dart';

class HomeScreen extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => HomeScreen());
  HomeScreen({super.key});

  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Users');

  final pages = const [
    UsersPage(),
    ChatPage(),
    StoriesPage(),
    CallsPage(),
    HelpPage(),
  ];

  final pageTitles = const [
    'Users',
    'Chat Messaging',
    'Activity Stories',
    'Video & Audio Call',
    'Help & Support',
    '',
  ];

  void _onNavigationItemSelected(index) {
    title.value = pageTitles[index];
    pageIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          __SideBar(onItemSelected: _onNavigationItemSelected),
          // Main Content
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: pageIndex,
              builder: (BuildContext context, int value, _) {
                return pages[value];
              },
            ),
          ),
        ],
      ),
    );
  }
}

class __SideBar extends StatefulWidget {
  const __SideBar({required this.onItemSelected});

  final ValueChanged<int> onItemSelected;

  @override
  State<__SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<__SideBar>
    with SingleTickerProviderStateMixin {
  var selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(begin: 250, end: 70).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
      _isMinimized
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  void handleItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: true,
      bottom: false,
      top: false,
      child: AnimatedBuilder(
        animation: _widthAnimation,
        builder: (context, child) {
          return Container(
            width: _widthAnimation.value,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              color: const Color(0xFF1A1A1A),
            ),
            child: Column(
              children: [
                // Logo
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: _isMinimized ? 4 : 8,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          _isMinimized
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceAround,
                      children: [
                        !_isMinimized
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Image.asset(
                                    'assets/images/app_logo.png',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Chat App',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                            : SizedBox(width: 0),
                        IconButton(
                          icon: Icon(
                            _isMinimized
                                ? Icons.chevron_right
                                : Icons.chevron_left,
                          ),
                          onPressed: toggleMinimize,
                        ),
                      ],
                    ),
                  ),
                ),
                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      _MenuItem(
                        icon: Icons.account_circle_outlined,
                        title: 'Users',
                        index: 0,
                        isSelected: selectedIndex == 0,
                        onTap: handleItemSelected,
                        isMinimized: _isMinimized,
                      ),
                      _MenuItem(
                        icon: CupertinoIcons.bubble_left_bubble_right,
                        title: 'Chat Messaging',
                        index: 1,
                        isSelected: selectedIndex == 1,
                        onTap: handleItemSelected,
                        isMinimized: _isMinimized,
                      ),
                      _MenuItem(
                        icon: Icons.play_circle_outline,
                        title: 'Activity Stories',
                        index: 2,
                        isSelected: selectedIndex == 2,
                        onTap: handleItemSelected,
                        isMinimized: _isMinimized,
                      ),
                      _MenuItem(
                        icon: CupertinoIcons.phone,
                        title: 'Video & Audio Call',
                        index: 3,
                        isSelected: selectedIndex == 3,
                        onTap: handleItemSelected,
                        isMinimized: _isMinimized,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 130,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      _MenuItem(
                        icon: Icons.info_outline,
                        title: 'Help & Support',
                        index: 4,
                        isSelected: selectedIndex == 4,
                        onTap: handleItemSelected,
                        isMinimized: _isMinimized,
                      ),
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        title: 'Sign out',
                        index: 5,
                        isSelected: selectedIndex == 5,
                        onTap: handleItemSelected,
                        isMinimized: _isMinimized,
                        isSignOut: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.isMinimized = false,
    this.isSignOut = false,
  });

  final IconData icon;
  final String title;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;
  final bool isMinimized;
  final bool isSignOut;

  @override
  __MenuItemState createState() => __MenuItemState();
}

class __MenuItemState extends State<_MenuItem> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (value) {
        setState(() {
          isHovering = value;
        });
      },
      onTap:
          widget.isSignOut
              ? () => Navigator.of(context).pushReplacement(LoginScreen.route)
              : () => widget.onTap(widget.index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMinimized ? 16 : 8,
          vertical: 12,
        ),
        color:
            widget.isSelected
                ? AppColors.secondary
                : isHovering
                ? Colors.grey[800]
                : Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon),
            if (!widget.isMinimized) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.title,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
