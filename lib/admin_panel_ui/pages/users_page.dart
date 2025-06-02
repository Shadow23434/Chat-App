import 'package:chat_app/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/index.dart';
import 'package:chat_app/admin_panel_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:chat_app/admin_panel_ui/widgets/widgets.dart';
import 'package:chat_app/admin_panel_ui/services/index.dart';
import 'package:dio/dio.dart';

enum SortOption { ascending, descending }

enum AccountOption { signOut, info }

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isClicked = false;
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  bool _sortAscending = true;

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  List<UserModel> _paginatedUsers = [];
  int _totalUsers = 0;
  int _backendTotalPages = 0;

  // Stats counters
  int _maleCount = 0;
  int _femaleCount = 0;
  int _unknownGenderCount = 0;
  int _adminCount = 0;
  int _userCount = 0;
  int _totalNonAdminUsers = 0;
  int _filteredNonAdminUsers = 0;

  @override
  void initState() {
    super.initState();
    // Only load data if authenticated
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isAuthenticated) {
      _loadData();
    } else {
      // Potentially navigate to login or show a message
      setState(() {
        _isLoading = false;
      });
    }
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _users = [];
        _filteredUsers = [];
        _paginatedUsers = [];
        _totalUsers = 0;
        _backendTotalPages = 0;
        _maleCount = 0;
        _femaleCount = 0;
        _unknownGenderCount = 0;
        _adminCount = 0;
        _userCount = 0;
        _totalNonAdminUsers = 0;
        _filteredNonAdminUsers = 0;
      });

      final userService = Provider.of<UserService>(context, listen: false);

      // Gọi API với các tham số
      final response = await userService.getUsers(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchController.text,
        sort: _sortAscending ? 'asc' : 'desc',
        sortField: 'username',
      );

      if (!mounted) return;

      // Check if the response has the expected structure
      if (response['users'] is List &&
          response['stats'] is Map &&
          response['pagination'] is Map) {
        setState(() {
          _users =
              (response['users'] as List)
                  .map((user) => UserModel.fromJson(user))
                  .toList();
          final stats = response['stats'];
          _maleCount = stats['maleCount'];
          _femaleCount = stats['femaleCount'];
          _unknownGenderCount = stats['unknownGenderCount'];
          _adminCount = stats['adminCount'];
          _totalUsers = stats['totalUsers'];

          // Update user count from backend
          _userCount = stats['userCount'] ?? 0;

          // Update new stats fields from backend
          _totalNonAdminUsers = stats['totalUserCount'] ?? 0;
          _filteredNonAdminUsers = stats['filteredUserCount'] ?? 0;

          // Cập nhật thông tin phân trang
          final pagination = response['pagination'];
          _backendTotalPages = pagination['pages'];

          _isLoading = false;
          _updatePaginatedUsers();
        });
      } else {
        // Handle cases where the response is not in the expected JSON format
        // This might happen if the server returns an HTML error page
        print('Received unexpected response format: ${response.runtimeType}');
        print('Response data: $response');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _users = [];
            _filteredUsers = [];
            _paginatedUsers = [];
            _totalUsers = 0;
            _backendTotalPages = 0;
            _maleCount = 0;
            _femaleCount = 0;
            _unknownGenderCount = 0;
            _adminCount = 0;
            _userCount = 0;
            _totalNonAdminUsers = 0;
            _filteredNonAdminUsers = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              'Error',
              'Received unexpected data format from the server.',
              Icons.info_outline_rounded,
              AppColors.accent,
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Reset các giá trị về mặc định
          _users = [];
          _filteredUsers = [];
          _paginatedUsers = [];
          _totalUsers = 0;
          _backendTotalPages = 0;
          _maleCount = 0;
          _femaleCount = 0;
          _unknownGenderCount = 0;
          _adminCount = 0;
          _userCount = 0;
          _totalNonAdminUsers = 0;
          _filteredNonAdminUsers = 0;
        });

        // Hiển thị thông báo lỗi chi tiết hơn nếu có thông tin từ DioException
        String errorMessage = 'Failed to load users.';
        if (e.response != null) {
          errorMessage = 'Error: ${e.response!.statusCode}';
          if (e.response!.data != null) {
            // Attempt to parse error message from response data if it's a Map
            if (e.response!.data is Map &&
                e.response!.data.containsKey('message')) {
              errorMessage = 'Error: ${e.response!.data['message']}';
            } else {
              // If response data is not a Map (e.g., HTML), show a generic error
              errorMessage = 'Error: Received unexpected response from server.';
              print(
                'DioError Response Data: ${e.response!.data}',
              ); // Log unexpected data
            }
          }
        } else {
          errorMessage = 'Error: ${e.message ?? 'Unknown network error'}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Error',
            errorMessage,
            Icons.info_outline_rounded,
            AppColors.accent,
          ),
        );

        // Xử lý khi session hết hạn (based on error message content)
        if (errorMessage.contains('Session expired') ||
            errorMessage.contains('Not authenticated')) {
          Navigator.of(context).pushReplacement(AdminLogInScreen.route);
        }
      }
    } catch (e) {
      // Catch any other unexpected errors
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Reset các giá trị về mặc định
          _users = [];
          _filteredUsers = [];
          _paginatedUsers = [];
          _totalUsers = 0;
          _backendTotalPages = 0;
          _maleCount = 0;
          _femaleCount = 0;
          _unknownGenderCount = 0;
          _adminCount = 0;
          _userCount = 0;
          _totalNonAdminUsers = 0;
          _filteredNonAdminUsers = 0;
        });

        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Error',
            e.toString().replaceAll('Exception: ', ''),
            Icons.info_outline_rounded,
            AppColors.accent,
          ),
        );

        // Xử lý khi session hết hạn
        if (e.toString().contains('Session expired') ||
            e.toString().contains('Not authenticated')) {
          Navigator.of(context).pushReplacement(AdminLogInScreen.route);
        }
      }
    }
  }

  void _filterUsers() {
    setState(() {
      _currentPage = 1; // Reset về trang đầu tiên khi tìm kiếm
    });
    _loadData(); // Tải lại dữ liệu với từ khóa tìm kiếm mới
  }

  void _sortUsers() {
    setState(() {
      _currentPage = 1; // Reset về trang đầu tiên khi sắp xếp
    });
    _loadData(); // Tải lại dữ liệu với thứ tự sắp xếp mới
  }

  void _updatePaginatedUsers() {
    // Since _users now only contains items for the current page,
    // _paginatedUsers should just be _users.
    if (!mounted) return;
    setState(() {
      _paginatedUsers = List.from(_users);
    });
  }

  void _changePage(int page) {
    if (page >= 1 && page <= _backendTotalPages) {
      setState(() {
        _currentPage = page;
      });
      _loadData(); // Tải dữ liệu cho trang mới
    }
  }

  int get _totalPages {
    // Use the total pages from the backend
    return _backendTotalPages;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: const Text(
              'Users',
              style: TextStyle(color: AppColors.textLight, fontSize: 24),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search bar
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    textAlign: TextAlign.start,
                    onFieldSubmitted: (_) => _filterUsers(),
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, phone, role',
                      hintStyle: TextStyle(color: AppColors.textFaded),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconBorder(
                          icon: Icons.search_rounded,
                          color: AppColors.secondary,
                          size: 20,
                          onTap: () => _filterUsers(),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.cardView,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Avatar container
                PopupMenuButton<AccountOption>(
                  borderRadius: BorderRadius.circular(12),
                  offset: Offset(0, 58),
                  tooltip: '',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.cardView,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Avatar.small(
                            url:
                                Provider.of<AuthService>(
                                  context,
                                ).currentAdmin?.profilePic ??
                                '',
                            onTap: () {},
                          ),
                          SizedBox(width: 6),
                          Text(
                            Provider.of<AuthService>(
                                  context,
                                ).currentAdmin?.username ??
                                'Admin',
                            style: TextStyle(fontSize: 14),
                          ),
                          _isClicked
                              ? Icon(Icons.keyboard_arrow_up_rounded)
                              : Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ),
                  onOpened:
                      () => setState(() {
                        _isClicked = !_isClicked;
                      }),
                  onCanceled:
                      () => setState(() {
                        _isClicked = !_isClicked;
                      }),
                  onSelected: (AccountOption option) {
                    setState(() {
                      option == AccountOption.signOut
                          ? Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          )
                          : Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/account-info',
                            (route) => false,
                          );
                    });
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<AccountOption>>[
                        PopupMenuItem<AccountOption>(
                          value: AccountOption.info,
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 20),
                              SizedBox(width: 8),
                              Text('Your Account'),
                            ],
                          ),
                        ),
                        PopupMenuItem<AccountOption>(
                          value: AccountOption.signOut,
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Sign out'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              )
              : _users.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.textFaded,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No users found',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textFaded,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddNewUser(),
                        );
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add New User'),
                    ),
                  ],
                ),
              )
              : _Body(
                users: _paginatedUsers,
                allUsers: _users,
                currentPage: _currentPage,
                totalPages: _totalPages,
                itemsPerPage: _itemsPerPage,
                onPageChanged: _changePage,
                maleCount: _maleCount,
                femaleCount: _femaleCount,
                unknownCount: _unknownGenderCount,
                adminCount: _adminCount,
                onRefresh: _loadData,
                onSort: (SortOption option) {
                  setState(() {
                    _sortAscending = (option == SortOption.ascending);
                    _sortUsers();
                  });
                },
                totalUsers: _totalUsers,
                userCount: _userCount,
                totalNonAdminUsers: _totalNonAdminUsers,
                filteredNonAdminUsers: _filteredNonAdminUsers,
              ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.users,
    required this.allUsers,
    required this.onSort,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.maleCount,
    required this.femaleCount,
    required this.unknownCount,
    required this.adminCount,
    required this.onRefresh,
    required this.totalUsers,
    required this.userCount,
    required this.totalNonAdminUsers,
    required this.filteredNonAdminUsers,
  });
  final List<UserModel> users;
  final List<UserModel> allUsers;
  final void Function(SortOption) onSort;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final int maleCount;
  final int femaleCount;
  final int unknownCount;
  final int adminCount;
  final VoidCallback onRefresh;
  final int totalUsers;
  final int userCount;
  final int totalNonAdminUsers;
  final int filteredNonAdminUsers;

  @override
  Widget build(BuildContext context) {
    // Calculate overall total unfiltered users
    final overallTotalUnfilteredUsers = totalNonAdminUsers + adminCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Add, refresh icon
                  SizedBox(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Users',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddNewUser(),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.add),
                                        SizedBox(width: 4),
                                        Text(
                                          'Add User',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              IconNoBorder(
                                icon: Icons.refresh,
                                onTap: onRefresh,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CardList(
                    totalUsers: totalUsers,
                    maleCount: maleCount,
                    femaleCount: femaleCount,
                    unknownCount: unknownCount,
                    adminCount: adminCount,
                    userCount: userCount,
                    totalNonAdminUsers: totalNonAdminUsers,
                    filteredNonAdminUsers: filteredNonAdminUsers,
                  ),
                  SizedBox(height: 12),
                  // User's tabel
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.cardView,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      child:
                          (users.isEmpty)
                              ? Text('There is no user here. Try to add one.')
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'All Users',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  DataTable(
                                    columnSpacing: 10,
                                    columns: [
                                      DataColumn(
                                        label: Text('#'),
                                        columnWidth: FlexColumnWidth(0.1),
                                      ),
                                      DataColumn(
                                        columnWidth: FlexColumnWidth(0.2),
                                        label: Row(
                                          children: [
                                            Text('Name'),
                                            SizedBox(width: 4),
                                            PopupMenuButton<SortOption>(
                                              tooltip: '',
                                              icon: Icon(
                                                Icons.arrow_drop_down,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                              onSelected: (SortOption option) {
                                                onSort(option);
                                              },
                                              itemBuilder:
                                                  (BuildContext context) => <
                                                    PopupMenuEntry<SortOption>
                                                  >[
                                                    PopupMenuItem<SortOption>(
                                                      value:
                                                          SortOption.descending,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .keyboard_double_arrow_down,
                                                            size: 20,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Sort descending',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<SortOption>(
                                                      value:
                                                          SortOption.ascending,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .keyboard_double_arrow_up,
                                                            size: 20,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Sort ascending',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text('Email'),
                                        columnWidth: FlexColumnWidth(0.25),
                                      ),
                                      DataColumn(
                                        label: Text('Gender'),
                                        columnWidth: FlexColumnWidth(0.15),
                                      ),
                                      DataColumn(
                                        label: Text('Role'),
                                        columnWidth: FlexColumnWidth(0.15),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                        columnWidth: FlexColumnWidth(0.15),
                                      ),
                                    ],
                                    rows:
                                        users.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          UserModel user = entry.value;
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  '${(currentPage - 1) * itemsPerPage + index + 1}',
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ImageService.avatarImage(
                                                      url: user.profilePic,
                                                      radius: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        user.username,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  user.email,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  user.gender,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  user.role,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    IconNoBorder(
                                                      icon: Icons.edit,
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return EditUser(
                                                              id: user.id,
                                                              username:
                                                                  user.username,
                                                              email: user.email,
                                                              password: '',
                                                              phone:
                                                                  user.phoneNumber ??
                                                                  'Unknown',
                                                              gender:
                                                                  user.gender,
                                                              profilePic:
                                                                  user.profilePic,
                                                              role: user.role,
                                                            );
                                                          },
                                                        ).then((_) {
                                                          // Refresh the user list after editing
                                                          onRefresh();
                                                        });
                                                      },
                                                    ),
                                                    IconNoBorder(
                                                      icon:
                                                          Icons.delete_rounded,
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .cardView,
                                                              title: Text(
                                                                'Delete User',
                                                                style: TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .accent,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                'Are you sure you want to delete this user?',
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () =>
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop(),
                                                                  child: Text(
                                                                    'Cancel',
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () async {
                                                                    try {
                                                                      final userService = Provider.of<
                                                                        UserService
                                                                      >(
                                                                        context,
                                                                        listen:
                                                                            false,
                                                                      );
                                                                      await userService
                                                                          .deleteUser(
                                                                            user.id,
                                                                          );
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop();
                                                                      ScaffoldMessenger.of(
                                                                        context,
                                                                      ).showSnackBar(
                                                                        customSnackBar(
                                                                          'Success',
                                                                          'User deleted successfully',
                                                                          Icons
                                                                              .check_circle_outline,
                                                                          Colors
                                                                              .green,
                                                                        ),
                                                                      );
                                                                      // Refresh the user list
                                                                      onRefresh();
                                                                    } catch (
                                                                      e
                                                                    ) {
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop();
                                                                      ScaffoldMessenger.of(
                                                                        context,
                                                                      ).showSnackBar(
                                                                        customSnackBar(
                                                                          'Error',
                                                                          e.toString().replaceAll(
                                                                            'Exception: ',
                                                                            '',
                                                                          ),
                                                                          Icons
                                                                              .info_outline_rounded,
                                                                          AppColors
                                                                              .accent,
                                                                        ),
                                                                      );
                                                                    }
                                                                  },
                                                                  child: Text(
                                                                    'Delete',
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                  // Pagination controls
                                  if (totalPages > 1)
                                    PaginationControls(
                                      currentPage: currentPage,
                                      totalPages: totalPages,
                                      onPageChanged: onPageChanged,
                                      itemsPerPage: itemsPerPage,
                                      totalItems: totalUsers,
                                    ),
                                ],
                              ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Chart container
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Container(
                  height: 600,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.cardView,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Column(
                        children: [
                          _PieChart(
                            maleCount: maleCount,
                            femaleCount: femaleCount,
                            unknownCount: unknownCount,
                          ),
                          SizedBox(height: 12),
                          _GenderCard(
                            maleCount: maleCount,
                            femaleCount: femaleCount,
                            unknownCount: unknownCount,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({
    required this.totalUsers,
    required this.maleCount,
    required this.femaleCount,
    required this.unknownCount,
    required this.adminCount,
    required this.userCount,
    required this.totalNonAdminUsers,
    required this.filteredNonAdminUsers,
  });

  final int totalUsers;
  final int maleCount;
  final int femaleCount;
  final int unknownCount;
  final int adminCount;
  final int userCount;
  final int totalNonAdminUsers;
  final int filteredNonAdminUsers;

  @override
  Widget build(BuildContext context) {
    // Calculate overall total unfiltered users
    final overallTotalUnfilteredUsers = totalNonAdminUsers + adminCount;

    return SizedBox(
      height: 120,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 3,
          separatorBuilder: (context, index) => SizedBox(width: 12),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ProcessCard(
                  title: 'All',
                  subtile: '$totalUsers Person${totalUsers != 1 ? 's' : ''}',
                  icon: Icons.group,
                  value: 1,
                  color: AppColors.secondary,
                );
              case 1:
                return ProcessCard(
                  title: 'Users',
                  subtile:
                      '$totalNonAdminUsers Person${totalNonAdminUsers != 1 ? 's' : ''}',
                  icon: Icons.person_rounded,
                  value:
                      overallTotalUnfilteredUsers > 0
                          ? totalNonAdminUsers / overallTotalUnfilteredUsers
                          : 0,
                  color: Colors.green,
                );
              case 2:
                return ProcessCard(
                  title: 'Admin',
                  subtile: '$adminCount Person${adminCount != 1 ? 's' : ''}',
                  icon: Icons.admin_panel_settings_rounded,
                  value:
                      overallTotalUnfilteredUsers > 0
                          ? adminCount / overallTotalUnfilteredUsers
                          : 0,
                  color: Colors.deepOrange,
                );
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({
    required this.maleCount,
    required this.femaleCount,
    required this.unknownCount,
  });

  final int maleCount;
  final int femaleCount;
  final int unknownCount;

  @override
  Widget build(BuildContext context) {
    final total = maleCount + femaleCount + unknownCount;

    // Calculate percentages (avoid division by zero)
    final malePercentage = total > 0 ? (maleCount / total) * 100 : 0;
    final femalePercentage = total > 0 ? (femaleCount / total) * 100 : 0;
    final unknownPercentage = total > 0 ? (unknownCount / total) * 100 : 0;

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.deepPurple,
              value: maleCount.toDouble(),
              radius: 50,
              title: '${malePercentage.toStringAsFixed(0)}%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.pink,
              value: femaleCount.toDouble(),
              radius: 50,
              title: '${femalePercentage.toStringAsFixed(0)}%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.yellow,
              value: unknownCount.toDouble(),
              radius: 50,
              title: '${unknownPercentage.toStringAsFixed(0)}%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.maleCount,
    required this.femaleCount,
    required this.unknownCount,
  });

  final int maleCount;
  final int femaleCount;
  final int unknownCount;

  @override
  Widget build(BuildContext context) {
    final total = maleCount + femaleCount + unknownCount;

    return Expanded(
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return ProcessCard(
                title: 'Male',
                subtile: '$maleCount Person${maleCount != 1 ? 's' : ''}',
                icon: Icons.male_rounded,
                value: total > 0 ? maleCount / total : 0,
                color: Colors.deepPurple,
                hasBorder: true,
              );
            case 1:
              return ProcessCard(
                title: 'Female',
                subtile: '$femaleCount Person${femaleCount != 1 ? 's' : ''}',
                icon: Icons.female_rounded,
                value: total > 0 ? femaleCount / total : 0,
                color: Colors.pink,
                hasBorder: true,
              );
            case 2:
              return ProcessCard(
                title: 'Unknown',
                subtile: '$unknownCount Person${unknownCount != 1 ? 's' : ''}',
                icon: Icons.transgender_rounded,
                value: total > 0 ? unknownCount / total : 0,
                color: Colors.yellow,
                hasBorder: true,
              );
            default:
              return Container();
          }
        },
      ),
    );
  }
}
