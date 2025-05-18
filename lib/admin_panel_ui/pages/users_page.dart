import 'dart:convert';
import 'package:chat_app/admin_panel_ui/screens/screens.dart';
import 'package:chat_app/admin_panel_ui/widget/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/admin_panel_ui/services/image_service.dart';

enum SortOption { ascending, descending }

enum AccountOption { signOut, info }

// Custom User model for this page to handle JSON data properly
class UserData {
  final String id;
  final String username;
  final String email;
  final String? gender;
  final String? phoneNumber;
  final String profilePic;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    this.gender,
    this.phoneNumber,
    required this.profilePic,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id']['\$oid'],
      username: json['username'] ?? 'Unknown',
      email: json['email'] ?? '',
      gender: json['gender'] ?? 'Unknown',
      phoneNumber: json['phoneNumber'],
      profilePic: json['profilePic'] ?? '',
    );
  }
}

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
  List<UserData> _users = [];
  List<UserData> _filteredUsers = [];
  bool _isLoading = true;
  bool _sortAscending = true;

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  List<UserData> _paginatedUsers = [];

  // Stats counters
  int _maleCount = 0;
  int _femaleCount = 0;
  int _unknownGenderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _searchController.addListener(() {
      _filterUsers();
    });
  }

  Future<void> _loadData() async {
    try {
      // Load users from JSON file
      final String usersResponse = await rootBundle.loadString(
        'assets/demo_data/users.json',
      );
      final List<dynamic> usersData = json.decode(usersResponse);

      // Parse JSON data to UserData objects
      final loadedUsers =
          usersData.map((json) => UserData.fromJson(json)).toList();

      // Calculate gender stats
      int maleCount = 0;
      int femaleCount = 0;
      int unknownCount = 0;

      for (var user in loadedUsers) {
        if (user.gender?.toLowerCase() == 'male') {
          maleCount++;
        } else if (user.gender?.toLowerCase() == 'female') {
          femaleCount++;
        } else {
          unknownCount++;
        }
      }

      setState(() {
        _users = loadedUsers;
        _filteredUsers = List.from(_users);
        _maleCount = maleCount;
        _femaleCount = femaleCount;
        _unknownGenderCount = unknownCount;
        _isLoading = false;
        _updatePaginatedUsers();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers =
            _users.where((user) {
              return user.username.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  (user.phoneNumber != null &&
                      user.phoneNumber!.toLowerCase().contains(query));
            }).toList();
      }
      _sortUsers();
      _currentPage = 1; // Reset to first page when filtering
      _updatePaginatedUsers();
    });
  }

  void _sortUsers() {
    setState(() {
      _filteredUsers.sort((a, b) {
        return _sortAscending
            ? a.username.compareTo(b.username)
            : b.username.compareTo(a.username);
      });
      _updatePaginatedUsers();
    });
  }

  void _updatePaginatedUsers() {
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex =
        startIndex + _itemsPerPage > _filteredUsers.length
            ? _filteredUsers.length
            : startIndex + _itemsPerPage;

    if (startIndex >= _filteredUsers.length && _currentPage > 1) {
      // If current page has no items (e.g., after filtering), go to first page
      _currentPage = 1;
      _updatePaginatedUsers();
      return;
    }

    setState(() {
      _paginatedUsers = _filteredUsers.sublist(startIndex, endIndex);
    });
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
      _updatePaginatedUsers();
    });
  }

  int get _totalPages {
    return (_filteredUsers.length / _itemsPerPage).ceil();
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
                    decoration: InputDecoration(
                      hintText: 'Search by name, email or phone',
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
                                'https://th.bing.com/th/id/OIP.V1Pj5o3-zDgGCehHF2UFggHaHa?w=185&h=185&c=7&r=0&o=5&pid=1.7',
                            onTap: () {},
                          ),
                          SizedBox(width: 6),
                          Text('Admin', style: TextStyle(fontSize: 14)),
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
                          ? Navigator.of(
                            context,
                          ).pushReplacement(AdminLogInScreen.route)
                          : Navigator.of(
                            context,
                          ).pushReplacement(AccountInfo.route);
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
              : _Body(
                users: _paginatedUsers,
                allUsers: _filteredUsers,
                currentPage: _currentPage,
                totalPages: _totalPages,
                itemsPerPage: _itemsPerPage,
                onPageChanged: _changePage,
                maleCount: _maleCount,
                femaleCount: _femaleCount,
                unknownCount: _unknownGenderCount,
                onRefresh: _loadData,
                onSort: (SortOption option) {
                  setState(() {
                    _sortAscending = (option == SortOption.ascending);
                    _sortUsers();
                  });
                },
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
    required this.onRefresh,
  });
  final List<UserData> users;
  final List<UserData> allUsers;
  final void Function(SortOption) onSort;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final int maleCount;
  final int femaleCount;
  final int unknownCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
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
                                    builder: (context) {
                                      return AddNewUser();
                                    },
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
                    users: allUsers.length,
                    maleCount: maleCount,
                    femaleCount: femaleCount,
                    unknownCount: unknownCount,
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
                          (allUsers.isEmpty)
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
                                        columnWidth: FlexColumnWidth(0.1),
                                      ),
                                      DataColumn(
                                        label: Text('Phone Number'),
                                        columnWidth: FlexColumnWidth(0.2),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                        columnWidth: FlexColumnWidth(0.15),
                                      ),
                                    ],
                                    rows:
                                        users.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          UserData user = entry.value;
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
                                                  user.gender ?? 'Unknown',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  user.phoneNumber ?? 'Unknown',
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
                                                              username:
                                                                  user.username,
                                                              email: user.email,
                                                              password:
                                                                  'password',
                                                              phone:
                                                                  user.phoneNumber ??
                                                                  'Unknown',
                                                              gender:
                                                                  user.gender ??
                                                                  'Unknown',
                                                              profilePic:
                                                                  user.profilePic,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                    IconNoBorder(
                                                      icon:
                                                          Icons.delete_rounded,
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return DeleteUser();
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
                                  if (allUsers.length > itemsPerPage)
                                    PaginationControls(
                                      currentPage: currentPage,
                                      totalPages: totalPages,
                                      onPageChanged: onPageChanged,
                                      itemsPerPage: itemsPerPage,
                                      totalItems: allUsers.length,
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
          ],
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({
    required this.users,
    required this.maleCount,
    required this.femaleCount,
    required this.unknownCount,
  });

  final int users;
  final int maleCount;
  final int femaleCount;
  final int unknownCount;

  @override
  Widget build(BuildContext context) {
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
                  subtile: '$users Person${users != 1 ? 's' : ''}',
                  icon: Icons.group,
                  value: 1,
                  color: AppColors.secondary,
                );
              case 1:
                return ProcessCard(
                  title: 'Users',
                  subtile: '${users - 1} Person${users != 2 ? 's' : ''}',
                  icon: Icons.person_rounded,
                  value: (users - 1) / users,
                  color: Colors.green,
                );
              case 2:
                return ProcessCard(
                  title: 'Admin',
                  subtile: '1 Person',
                  icon: Icons.admin_panel_settings_rounded,
                  value: 1 / users,
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
