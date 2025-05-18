import 'dart:convert';
import 'package:chat_app/admin_panel_ui/models/models.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/theme.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/admin_panel_ui/widget/widgets.dart';
import 'package:chat_app/admin_panel_ui/services/image_service.dart';

// Define a custom User class specifically for this page to handle the JSON correctly
class UserData {
  final String id;
  final String username;
  final String email;
  final String profilePic;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePic,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id']?['\$oid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePic: json['profilePic'] ?? '',
    );
  }
}

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _sortAscending = false;
  List<Call> _calls = [];
  List<Call> _filteredCalls = [];
  List<UserData> _users = [];
  Map<String, UserData> _userMap = {};
  bool _isLoading = true;
  String _selectedFilter = 'All';

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  List<Call> _paginatedCalls = [];

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
      _filterCalls();
    });
  }

  Future<void> _loadData() async {
    try {
      // Load users first
      final String usersResponse = await rootBundle.loadString(
        'assets/demo_data/users.json',
      );
      final List<dynamic> usersData = json.decode(usersResponse);

      _users = usersData.map((json) => UserData.fromJson(json)).toList();
      // Create a map for easy lookup
      _userMap = {for (var user in _users) user.id: user};

      // Then load calls
      final String callsResponse = await rootBundle.loadString(
        'assets/demo_data/calls.json',
      );
      final List<dynamic> data = json.decode(callsResponse);
      setState(() {
        _calls = data.map((json) => Call.fromJson(json)).toList();
        _filteredCalls = List.from(_calls);
        _isLoading = false;
      });
      _sortCalls();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading data: $e');
    }
  }

  String _getUserEmail(String userId) {
    final user = _userMap[userId];
    return user?.email ?? 'Unknown User';
  }

  String? _getUserProfilePic(String userId) {
    final user = _userMap[userId];
    return user?.profilePic;
  }

  void _filterCalls() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCalls =
            _calls.where((call) {
              if (_selectedFilter == 'All') return true;
              if (_selectedFilter == 'Received')
                return call.status == 'received';
              if (_selectedFilter == 'Missed') return call.status == 'missed';
              return true;
            }).toList();
      } else {
        _filteredCalls =
            _calls.where((call) {
              // Search by caller or receiver email
              String callerEmail = _getUserEmail(call.callerId);
              String receiverEmail = _getUserEmail(call.receiverId);

              bool matchesQuery =
                  callerEmail.toLowerCase().contains(query) ||
                  receiverEmail.toLowerCase().contains(query) ||
                  call.status.toLowerCase().contains(query);

              bool matchesFilter = true;
              if (_selectedFilter == 'Received')
                matchesFilter = call.status == 'received';
              if (_selectedFilter == 'Missed')
                matchesFilter = call.status == 'missed';

              return matchesQuery && matchesFilter;
            }).toList();
      }
      _sortCalls();
      _updatePaginatedCalls();
    });
  }

  void _sortCalls() {
    setState(() {
      _filteredCalls.sort((a, b) {
        return _sortAscending
            ? a.startedAt.compareTo(b.startedAt)
            : b.startedAt.compareTo(a.startedAt);
      });
      _updatePaginatedCalls();
    });
  }

  void _updatePaginatedCalls() {
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex =
        startIndex + _itemsPerPage > _filteredCalls.length
            ? _filteredCalls.length
            : startIndex + _itemsPerPage;

    if (startIndex >= _filteredCalls.length && _currentPage > 1) {
      // If current page has no items (e.g., after filtering), go to previous page
      _currentPage = 1;
      _updatePaginatedCalls();
      return;
    }

    _paginatedCalls = _filteredCalls.sublist(startIndex, endIndex);
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
      _updatePaginatedCalls();
    });
  }

  int get _totalPages {
    return (_filteredCalls.length / _itemsPerPage).ceil();
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterCalls();
    });
  }

  void _toggleSort() {
    setState(() {
      _sortAscending = !_sortAscending;
      _sortCalls();
    });
  }

  void _deleteCall(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Call Record'),
            content: Text('Are you sure you want to delete this call record?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _calls.removeWhere((call) => call.id == id);
                    _filteredCalls.removeWhere((call) => call.id == id);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Call record deleted successfully')),
                  );
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _viewCallDetails(Call call) {
    final callerEmail = _getUserEmail(call.callerId);
    final receiverEmail = _getUserEmail(call.receiverId);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Call Details'),
            content: Container(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: call.statusColor.withOpacity(0.2),
                          child: Icon(
                            call.statusIcon,
                            color: call.statusColor,
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              call.status.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: call.statusColor,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              call.formattedDate,
                              style: TextStyle(color: AppColors.textFaded),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _detailItem('ID', call.id),
                    _detailItem('Caller Email', callerEmail),
                    _detailItem('Receiver Email', receiverEmail),
                    _detailItem(
                      'Duration',
                      call.duration > 0
                          ? call.formattedDuration
                          : 'No duration (missed)',
                    ),
                    _detailItem(
                      'Started At',
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(call.startedAt),
                    ),
                    if (call.endedAt != null)
                      _detailItem(
                        'Ended At',
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(call.endedAt!),
                      ),
                    _detailItem(
                      'Created',
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(call.createdAt),
                    ),
                    _detailItem(
                      'Updated',
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(call.updatedAt),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCall(call.id);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
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
              'Calls',
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
                      hintText: 'Search by name, or email',
                      hintStyle: TextStyle(color: AppColors.textFaded),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconBorder(
                          icon: Icons.search_rounded,
                          color: AppColors.secondary,
                          size: 20,
                          onTap: () => _filterCalls(),
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
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _filterButton('All', _selectedFilter == 'All'),
                        SizedBox(width: 8),
                        _filterButton(
                          'Received',
                          _selectedFilter == 'Received',
                        ),
                        SizedBox(width: 8),
                        _filterButton('Missed', _selectedFilter == 'Missed'),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            _sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: AppColors.secondary,
                          ),
                          onPressed: _toggleSort,
                          tooltip:
                              _sortAscending ? 'Oldest first' : 'Newest first',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredCalls.isEmpty
                            ? Center(child: Text('No calls found'))
                            : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.all(16),
                                    itemCount: _paginatedCalls.length,
                                    itemBuilder: (context, index) {
                                      final call = _paginatedCalls[index];
                                      return _buildCallItem(call);
                                    },
                                  ),
                                ),
                                // Pagination controls
                                if (_filteredCalls.length > _itemsPerPage)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: PaginationControls(
                                      currentPage: _currentPage,
                                      totalPages: _totalPages,
                                      onPageChanged: _changePage,
                                      itemsPerPage: _itemsPerPage,
                                      totalItems: _filteredCalls.length,
                                    ),
                                  ),
                              ],
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _filterButton(String label, bool isSelected) {
    return ElevatedButton(
      onPressed: () => _changeFilter(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.secondary : AppColors.cardView,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildCallItem(Call call) {
    final callerEmail = _getUserEmail(call.callerId);
    final receiverEmail = _getUserEmail(call.receiverId);
    final callerProfilePic = _getUserProfilePic(call.callerId);
    final receiverProfilePic = _getUserProfilePic(call.receiverId);

    return Card(
      color: AppColors.cardView,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _viewCallDetails(call),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: call.statusColor.withOpacity(0.2),
                child: Icon(call.statusIcon, color: call.statusColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Caller: ',
                          style: TextStyle(
                            color: AppColors.textFaded,
                            fontSize: 14,
                          ),
                        ),
                        ImageService.avatarImage(
                          url: callerProfilePic,
                          radius: 10,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            callerEmail,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Receiver: ',
                          style: TextStyle(
                            color: AppColors.textFaded,
                            fontSize: 14,
                          ),
                        ),
                        ImageService.avatarImage(
                          url: receiverProfilePic,
                          radius: 10,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            receiverEmail,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    call.formattedDate,
                    style: TextStyle(color: AppColors.textFaded, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(call.formattedTime, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    call.duration > 0 ? call.formattedDuration : 'No duration',
                    style: TextStyle(
                      color: call.duration > 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 20),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                        onTap:
                            () => Future.delayed(
                              Duration(seconds: 0),
                              () => _viewCallDetails(call),
                            ),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap:
                            () => Future.delayed(
                              Duration(seconds: 0),
                              () => _deleteCall(call.id),
                            ),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
