import 'package:flutter/material.dart';
import 'package:chat_app/core/models/index.dart';
import 'chat_list_header.dart';
import 'chat_card_list.dart';
import 'chat_table.dart';
import '../analytics/chat_analytics.dart';

class ChatPageBody extends StatelessWidget {
  const ChatPageBody({
    super.key,
    required this.chats,
    required this.allChats,
    required this.isLoading,
    required this.onDelete,
    required this.onRefresh,
    required this.onDeleteMessage,
    required this.onViewUserDetails,
    required this.downloadChatData,
    required this.totalMessages,
    required this.textMessages,
    required this.imageMessages,
    required this.audioMessages,
    required this.totalUnreadMessages,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.itemsPerPage,
    required this.onDeleteConfirmation,
    required this.totalChatsCount,
    required this.onDownloadAllChats,
  });

  final List<ChatModel> chats;
  final List<ChatModel> allChats;
  final bool isLoading;
  final Function(String) onDelete;
  final VoidCallback onRefresh;
  final Function(String) onDeleteMessage;
  final Function(UserModel) onViewUserDetails;
  final Function(ChatModel?) downloadChatData;
  final int totalMessages;
  final int textMessages;
  final int imageMessages;
  final int audioMessages;
  final int totalUnreadMessages;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int itemsPerPage;
  final Function(BuildContext, ChatModel, Function(String))
  onDeleteConfirmation;
  final int totalChatsCount;
  final VoidCallback onDownloadAllChats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ChatListHeader(
                    onDownload: onDownloadAllChats,
                    onRefresh: onRefresh,
                  ),
                  ChatCardList(
                    totalChats: totalChatsCount,
                    totalMessages: totalMessages,
                  ),
                  const SizedBox(height: 12),
                  ChatTable(
                    chats: chats,
                    isLoading: isLoading,
                    currentPage: currentPage,
                    itemsPerPage: itemsPerPage,
                    onViewUserDetails: onViewUserDetails,
                    onDelete: onDelete,
                    downloadChatData: downloadChatData,
                    onPageChanged: onPageChanged,
                    totalPages: totalPages,
                    totalItems: totalChatsCount,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ChatAnalytics(
              totalMessages: totalMessages,
              textMessages: textMessages,
              imageMessages: imageMessages,
              audioMessages: audioMessages,
              totalUnreadMessages: totalUnreadMessages,
            ),
          ),
        ],
      ),
    );
  }
}
