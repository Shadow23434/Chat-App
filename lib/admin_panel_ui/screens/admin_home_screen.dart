import 'package:chat_app/admin_panel_ui/pages/pages.dart';
import 'package:chat_app/core/navigation/web_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Users');

  // Cache for page instances to maintain state
  final Map<int, Widget> _pageCache = {};

  // Initialize the page widgets with an empty container for lazy loading
  late final List<Widget> pages;

  final List<String> pageTitles = const [
    'Users',
    'Chat Messaging',
    'Activity Stories',
    'Video & Audio Call',
    'Help & Support',
  ];

  final List<String> pageRoutes = const [
    '/admin/users',
    '/admin/chats',
    '/admin/stories',
    '/admin/calls',
    '/admin/help',
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize pages list with page builder functions
    _initPages();
    // Set initial page based on current route
    _initPageFromRoute();
  }

  void _initPages() {
    // Create page widgets on demand to preserve state
    pages = List.generate(5, (index) => _buildLazyPage(index));
  }

  // Build a page only when it's accessed for the first time
  Widget _buildLazyPage(int index) {
    // Return from cache if exists
    if (_pageCache.containsKey(index)) {
      return _pageCache[index]!;
    }

    // Create and cache page based on index
    Widget page;
    switch (index) {
      case 0:
        page = const UsersPage();
        break;
      case 1:
        page = const ChatPage();
        break;
      case 2:
        page = const StoriesPage();
        break;
      case 3:
        page = const CallsPage();
        break;
      case 4:
        page = const HelpPage();
        break;
      default:
        page = const Center(child: Text('Page not found'));
    }

    // Cache the page instance for future use
    _pageCache[index] = page;
    return page;
  }

  void _initPageFromRoute() {
    final currentPath = WebNavigation.getCurrentPath();

    // Find matching route index
    int routeIndex = pageRoutes.indexOf(currentPath);

    // Default to users page if route not found
    if (routeIndex == -1) routeIndex = 0;

    // Set page index and title
    pageIndex.value = routeIndex;
    title.value = pageTitles[routeIndex];
  }

  void _onNavigationItemSelected(int index) {
    // Update UI
    title.value = pageTitles[index];
    pageIndex.value = index;

    // Update URL without refreshing page
    final path = pageRoutes[index];

    // Use browser history API to update URL without page reload
    WebNavigation.updateUrlWithoutReload(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          __SideBar(
            onItemSelected: _onNavigationItemSelected,
            currentIndex: pageIndex.value,
          ),
          // Main Content
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: pageIndex,
              builder: (BuildContext context, int value, _) {
                // Using IndexedStack to preserve state of all pages
                return IndexedStack(index: value, children: pages);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class __SideBar extends StatefulWidget {
  const __SideBar({required this.onItemSelected, required this.currentIndex});

  final ValueChanged<int> onItemSelected;
  final int currentIndex;

  @override
  State<__SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<__SideBar>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(begin: 250, end: 70).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(__SideBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        selectedIndex = widget.currentIndex;
      });
    }
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
              ? () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              )
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
