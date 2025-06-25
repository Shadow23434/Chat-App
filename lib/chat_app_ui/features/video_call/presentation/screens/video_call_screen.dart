import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_app/core/config/index.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomName;
  final String identity;

  const VideoCallScreen({
    super.key,
    required this.roomName,
    required this.identity,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Room? _room;
  bool _isConnecting = true;
  bool _isMicMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    setState(() => _isConnecting = true);

    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/client/call/twilio-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identity': widget.identity,
          'room': widget.roomName,
        }),
      );

      final data = jsonDecode(response.body);
      final token = data['token'];

      if (token == null) {
        throw Exception(data['message'] ?? 'Không lấy được token từ server');
      }

      final room = await TwilioProgrammableVideo.connect(
        ConnectOptions(token, roomName: widget.roomName),
      );

      setState(() {
        _room = room;
        _isConnecting = false;
      });
    } catch (e) {
      setState(() => _isConnecting = false);
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Lỗi'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
      );
    }
  }

  @override
  void dispose() {
    _room?.disconnect();
    super.dispose();
  }

  void _toggleMic() {
    final localAudioTrack =
        _room?.localParticipant?.localAudioTracks.firstOrNull?.localAudioTrack;
    if (localAudioTrack != null) {
      localAudioTrack.enable(!_isMicMuted);
      setState(() => _isMicMuted = !_isMicMuted);
    }
  }

  void _toggleCamera() {
    final localVideoTrack =
        _room?.localParticipant?.localVideoTracks.firstOrNull?.localVideoTrack;
    if (localVideoTrack != null) {
      localVideoTrack.enable(!_isCameraOff);
      setState(() => _isCameraOff = !_isCameraOff);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnecting) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    final remoteParticipant =
        _room?.remoteParticipants.isNotEmpty == true
            ? _room!.remoteParticipants.first
            : null;

    return Scaffold(
      appBar: AppBar(title: Text('Video Call: ${widget.roomName}')),
      body: Stack(
        children: [
          // Remote video placeholder
          if (remoteParticipant != null &&
              remoteParticipant.remoteVideoTracks.isNotEmpty)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[800],
              child: const Center(
                child: Text(
                  'Remote Video',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          // Local video placeholder (small preview)
          Positioned(
            right: 16,
            bottom: 100,
            child:
                _room?.localParticipant?.localVideoTracks.isNotEmpty == true
                    ? Container(
                      width: 120,
                      height: 160,
                      color: Colors.grey[600],
                      child: const Center(
                        child: Text(
                          'Local Video',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    )
                    : const SizedBox(),
          ),
          // Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic),
                    color: Colors.white,
                    onPressed: _toggleMic,
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: Icon(
                      _isCameraOff ? Icons.videocam_off : Icons.videocam,
                    ),
                    color: Colors.white,
                    onPressed: _toggleCamera,
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.call_end),
                    color: Colors.red,
                    onPressed: () {
                      _room?.disconnect();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
