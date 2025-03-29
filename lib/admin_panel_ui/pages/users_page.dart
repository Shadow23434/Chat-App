import 'package:chat_app/admin_panel_ui/models/users.dart';
import 'package:chat_app/admin_panel_ui/screens/account_info.dart';
import 'package:chat_app/admin_panel_ui/screens/screens.dart';
import 'package:chat_app/admin_panel_ui/widget/widgets.dart';
import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
  List<User> _filteredUsers = [];
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(users);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _searchController.addListener(() {
      _filterUsers();
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(users);
      } else {
        _filteredUsers =
            users.where((user) {
              return user.name.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  user.phoneNumber.toLowerCase().contains(query);
            }).toList();
      }
      _sortUsers();
    });
  }

  void _sortUsers() {
    setState(() {
      _filteredUsers.sort((a, b) {
        return _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name);
      });
    });
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
                      hintText: 'Search',
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
                        spacing: 6,
                        children: [
                          Avatar.small(
                            url:
                                'https://th.bing.com/th/id/OIP.V1Pj5o3-zDgGCehHF2UFggHaHa?w=185&h=185&c=7&r=0&o=5&pid=1.7',
                            onTap: () {},
                          ),
                          Text('Gordon Amat', style: TextStyle(fontSize: 14)),
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
                          ).pushReplacement(LoginScreen.route)
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
      body: _Body(
        users: _filteredUsers,
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
  const _Body({required this.users, required this.onSort});
  final List<User> users;
  final void Function(SortOption) onSort;

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
                              IconNoBorder(icon: Icons.refresh, onTap: () {}),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CardList(users: users),
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
                                          User user = entry.value;
                                          return DataRow(
                                            cells: [
                                              DataCell(Text('${index + 1}')),
                                              DataCell(
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Avatar.small(
                                                      url: user.profileUrl,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        user.name,
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
                                                                  user.name,
                                                              email: user.email,
                                                              password:
                                                                  user.password,
                                                              phone:
                                                                  user.phoneNumber ??
                                                                  'Unknown',
                                                              gender:
                                                                  user.gender,
                                                              profilePic:
                                                                  user.profileUrl,
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
                        _PieChart(),
                        SizedBox(height: 12),
                        _GenderCard(),
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
  const _CardList({required this.users});

  final List<User> users;

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
                  subtile: '${users.length} Person',
                  icon: Icons.group,
                  value: 1,
                  color: AppColors.secondary,
                );
              case 1:
                return ProcessCard(
                  title: 'Users',
                  subtile: '18 Person',
                  icon: Icons.person_rounded,
                  value: 8 / 9,
                  color: Colors.green,
                );
              case 2:
                return ProcessCard(
                  title: 'Admin',
                  subtile: '2 Person',
                  icon: Icons.admin_panel_settings_rounded,
                  value: 2 / 9,
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
  const _PieChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.deepPurple,
              value: 45,
              radius: 50,
              title: '45%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.pink,
              value: 45,
              radius: 50,
              title: '45%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.yellow,
              value: 10,
              radius: 50,
              title: '10%',
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
  const _GenderCard();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return ProcessCard(
                title: 'Male',
                subtile: '9 Person',
                icon: Icons.male_rounded,
                value: 9 / 20,
                color: Colors.deepPurple,
                hasBorder: true,
              );
            case 1:
              return ProcessCard(
                title: 'Female',
                subtile: '9 Person',
                icon: Icons.female_rounded,
                value: 9 / 20,
                color: Colors.pink,
                hasBorder: true,
              );
            case 2:
              return ProcessCard(
                title: 'Unknown',
                subtile: '2 Person',
                icon: Icons.transgender_rounded,
                value: 2 / 20,
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
