import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;
  String? _currentServerUrl;
  String? _currentChatId;

  void connect({required String serverUrl, required String chatId}) {
    print('SocketService: Connecting to $serverUrl with chatId: $chatId');

    // If already connected to the same server, just join the chat
    if (_socket != null &&
        _socket!.connected &&
        _currentServerUrl == serverUrl) {
      print('SocketService: Already connected, joining chat: $chatId');
      _socket!.emit('joinChat', chatId);
      _currentChatId = chatId;
      return;
    }

    // If connected to different server, disconnect first
    if (_socket != null && _socket!.connected) {
      print('SocketService: Disconnecting from previous connection');
      _socket!.disconnect();
    }

    _currentServerUrl = serverUrl;
    _currentChatId = chatId;

    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();
    _socket!.onConnect((_) {
      print('SocketService: Socket connected to $serverUrl');
      _socket!.emit('joinChat', chatId);
    });
    _socket!.onDisconnect((_) => print('SocketService: Socket disconnected'));
    _socket!.onConnectError(
      (err) => print('SocketService: Socket connect error: $err'),
    );
    _socket!.onError((err) => print('SocketService: Socket error: $err'));
  }

  void disconnect() {
    print('SocketService: Disconnecting socket');
    _socket?.disconnect();
    _socket = null;
    _currentServerUrl = null;
    _currentChatId = null;
  }

  void sendMessage(Map<String, dynamic> message) {
    print('SocketService: Sending message: $message');
    if (_socket != null && _socket!.connected) {
      _socket!.emit('sendMessage', message);
    } else {
      print('SocketService: Cannot send message - socket not connected');
    }
  }

  void onNewMessage(Function(dynamic) handler) {
    print('SocketService: Setting up newMessage listener');
    _socket?.on('newMessage', handler);
  }

  void offNewMessage(Function(dynamic) handler) {
    print('SocketService: Removing newMessage listener');
    _socket?.off('newMessage', handler);
  }

  // New methods for chat list updates
  void onChatUpdate(Function(dynamic) handler) {
    print('SocketService: Setting up chatUpdate listener');
    _socket?.on('chatUpdate', handler);
  }

  void offChatUpdate(Function(dynamic) handler) {
    print('SocketService: Removing chatUpdate listener');
    _socket?.off('chatUpdate', handler);
  }

  void onNewChat(Function(dynamic) handler) {
    print('SocketService: Setting up newChat listener');
    _socket?.on('newChat', handler);
  }

  void offNewChat(Function(dynamic) handler) {
    print('SocketService: Removing newChat listener');
    _socket?.off('newChat', handler);
  }

  // Method to join user's chat room for real-time updates
  void joinUserChats(String userId) {
    print('SocketService: Joining user chats room for user: $userId');
    if (_socket != null && _socket!.connected) {
      _socket!.emit('joinUserChats', userId);
    } else {
      print('SocketService: Cannot join user chats - socket not connected');
    }
  }

  // Method to leave user's chat room
  void leaveUserChats(String userId) {
    print('SocketService: Leaving user chats room for user: $userId');
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leaveUserChats', userId);
    }
  }

  // Method to set up connection callback
  void onConnect(Function() callback) {
    print('SocketService: Setting up connect callback');
    _socket?.onConnect((_) => callback());
  }
}
