import 'package:chat_app/admin_panel_ui/widgets/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/models/index.dart';
import 'package:chat_app/theme.dart';
import 'chat_participants.dart';
import 'chat_actions.dart';
import 'package:intl/intl.dart';

class ChatTable extends StatelessWidget {
  const ChatTable({
    super.key,
    required this.chats,
    required this.isLoading,
    required this.currentPage,
    required this.itemsPerPage,
    required this.onViewUserDetails,
    required this.onDelete,
    required this.downloadChatData,
    required this.onPageChanged,
    required this.totalPages,
    required this.totalItems,
  });

  final List<ChatModel> chats;
  final bool isLoading;
  final int currentPage;
  final int itemsPerPage;
  final Function(UserModel) onViewUserDetails;
  final Function(String) onDelete;
  final Function(ChatModel?) downloadChatData;
  final Function(int) onPageChanged;
  final int totalPages;
  final int totalItems;

  void _showDeleteConfirmation(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: const Text(
              'Are you sure you want to delete this chat? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete(chatId);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.cardView,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                )
                : totalItems == 0
                ? const Text('There are no chats to display.')
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Chats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DataTable(
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                          label: Text('#'),
                          columnWidth: FlexColumnWidth(0.1),
                        ),
                        DataColumn(
                          label: Text('Chat ID'),
                          columnWidth: FlexColumnWidth(0.2),
                        ),
                        DataColumn(
                          label: Text('Participants'),
                          columnWidth: FlexColumnWidth(0.2),
                        ),
                        DataColumn(
                          label: Text('Last message at'),
                          columnWidth: FlexColumnWidth(0.3),
                        ),
                        DataColumn(
                          label: Text('Actions'),
                          columnWidth: FlexColumnWidth(0.2),
                        ),
                      ],
                      rows:
                          chats.asMap().entries.map((entry) {
                            int index = entry.key;
                            ChatModel chat = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    '${(currentPage - 1) * itemsPerPage + index + 1}',
                                  ),
                                ),
                                DataCell(
                                  Tooltip(
                                    message: chat.id,
                                    child: Text(
                                      '${chat.id.substring(0, 8)}...',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  ChatParticipants(
                                    participants: chat.participants,
                                    onViewUserDetails: onViewUserDetails,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    chat.lastMessageAt != null
                                        ? DateFormat(
                                          'yyyy-MM-dd HH:mm',
                                        ).format(chat.lastMessageAt!)
                                        : 'N/A',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  ChatActions(
                                    chat: chat,
                                    onDelete:
                                        (String id) => _showDeleteConfirmation(
                                          context,
                                          id,
                                        ),
                                    downloadChatData: downloadChatData,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                    if (totalItems > itemsPerPage)
                      PaginationControls(
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onPageChanged: onPageChanged,
                        itemsPerPage: itemsPerPage,
                        totalItems: totalItems,
                      ),
                  ],
                ),
      ),
    );
  }
}
