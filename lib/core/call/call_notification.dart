class CallNotification {
  final String callerId;
  final String callerName;
  final String callerAvatar;
  final String channelId;
  final bool isVideo;

  CallNotification({
    required this.callerId,
    required this.callerName,
    required this.callerAvatar,
    required this.channelId,
    required this.isVideo,
  });
}
