import 'package:chat_app/core/models/index.dart';
import 'package:chat_app/admin_panel_ui/widgets/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/admin_panel_ui/services/index.dart';

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
  final CallService _callService = CallService();
  bool _isFocused = false;
  bool _sortAscending = false;
  List<CallModel> _calls = [];
  List<CallModel> _filteredCalls = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  int _totalPages = 1;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
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
      });

      final result = await _callService.getCalls(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchController.text,
        status: _selectedFilter != 'All' ? _selectedFilter : null,
        sort: _sortAscending ? 'asc' : 'desc',
      );

      setState(() {
        _calls = result['calls'];
        _filteredCalls = _calls;
        _totalItems = result['pagination']['total'];
        _totalPages = result['pagination']['pages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Error',
          'Error loading calls: $e',
          Icons.info_outline_rounded,
          AppColors.accent,
        ),
      );
    }
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
      _loadData();
    });
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _currentPage = 1;
      _loadData();
    });
  }

  void _toggleSort() {
    setState(() {
      _sortAscending = !_sortAscending;
      _loadData();
    });
  }

  Future<void> _deleteCall(String id) async {
    try {
      print('Attempting to delete call with ID: $id');
      await _callService.deleteCall(id);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Success',
          'Call deleted successfully',
          Icons.check_circle_outline_outlined,
          Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Error',
          'Error deleting call: $e',
          Icons.info_outline_rounded,
          AppColors.accent,
        ),
      );
    }
  }

  void _viewCallDetails(CallModel call) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Call Details'),
            content: SizedBox(
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
                          backgroundColor:
                              call.status == 'received'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                          child: Icon(
                            call.status == 'received'
                                ? Icons.call_received
                                : Icons.call_missed,
                            color:
                                call.status == 'received'
                                    ? Colors.green
                                    : Colors.red,
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
                                color:
                                    call.status == 'received'
                                        ? Colors.green
                                        : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              call.startedAt.toLocal().toString(),
                              style: TextStyle(color: AppColors.textFaded),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _detailItem('ID', call.id),
                    _detailItem('Caller', call.caller.email),
                    _detailItem('Receiver', call.receiver.email),
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
                          onTap: () => _loadData(),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.cardView,
                    ),
                    onFieldSubmitted: (_) => _loadData(),
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
                                    itemCount: _filteredCalls.length,
                                    itemBuilder: (context, index) {
                                      final call = _filteredCalls[index];
                                      return _buildCallItem(call);
                                    },
                                  ),
                                ),
                                if (_totalItems > _itemsPerPage)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: PaginationControls(
                                      currentPage: _currentPage,
                                      totalPages: _totalPages,
                                      onPageChanged: _changePage,
                                      itemsPerPage: _itemsPerPage,
                                      totalItems: _totalItems,
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

  Widget _buildCallItem(CallModel call) {
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
                backgroundColor:
                    call.status == 'received'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                child: Icon(
                  call.status == 'received'
                      ? Icons.call_received
                      : Icons.call_missed,
                  color: call.status == 'received' ? Colors.green : Colors.red,
                ),
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
                          url: call.caller.profilePic,
                          radius: 10,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            call.caller.email,
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
                          url: call.receiver.profilePic,
                          radius: 10,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            call.receiver.email,
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
                    call.startedAt.toLocal().toString(),
                    style: TextStyle(color: AppColors.textFaded, fontSize: 12),
                  ),
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
