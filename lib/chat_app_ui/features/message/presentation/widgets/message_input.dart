import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/bloc/message_bloc.dart';
import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/widgets/message_input/audio_helpers.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/widgets/message_input/image_helpers.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/widgets/message_input/audio_preview_overlay.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/widgets/message_input/image_preview_overlay.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/widgets/message_input/recording_overlay.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/utils/socket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({super.key, required this.chatId});

  final String chatId;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  XFile? _pickedImage;
  Timer? _recordTimer;
  int _recordDuration = 0;
  String? _recordedAudioPath;
  ap.AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  PlayerController? _playerController;
  Duration? _audioDuration;
  OverlayEntry? _imageOverlayEntry;
  OverlayEntry? _audioOverlayEntry;
  OverlayEntry? _recordingOverlayEntry;
  RecorderController? _recorderController;
  bool _isSendingImage = false;

  late final SocketService socketService;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _playerController = PlayerController();
    _recorderController = RecorderController();
    _audioPlayer = ap.AudioPlayer();
    socketService = SocketService();
    final socketUrl = dotenv.env['SOCKET_IO_URL'];
    socketService.connect(serverUrl: socketUrl!, chatId: widget.chatId);
    socketService.onNewMessage(_onSocketNewMessage);
  }

  @override
  void dispose() {
    _removeImageOverlay();
    _removeAudioOverlay();
    _removeRecordingOverlay();
    _audioRecorder.dispose();
    _audioPlayer?.dispose();
    _playerController?.dispose();
    _recordTimer?.cancel();
    socketService.offNewMessage(_onSocketNewMessage);
    socketService.disconnect();
    super.dispose();
  }

  void _onSocketNewMessage(dynamic data) {
    final message = MessageModel.fromJson(data);
    context.read<MessageBloc>().add(AddMessageEvent(message: message));
  }

  void _startRecordTimer() {
    _recordDuration = 0;
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        _recordDuration++;
      });
      if (_recordDuration >= 600) {
        // 10 min = 600 sec
        await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _stopRecordTimer();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording time limit reached (10 minutes)!'),
          ),
        );
      }
    });
  }

  void _stopRecordTimer() {
    _recordTimer?.cancel();
    _recordDuration = 0;
  }

  Future<void> _pickImage() async {
    print('MessageInput: _pickImage called');
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image to reduce size
      );
      if (pickedFile != null) {
        print('MessageInput: Image picked: ${pickedFile.path}');
        setState(() {
          _pickedImage = pickedFile;
        });
        _showImagePreviewOverlay();
      } else {
        print('MessageInput: No image selected');
      }
    } catch (e) {
      print('MessageInput: Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  void _showImagePreviewOverlay() {
    if (_pickedImage == null) return;
    _imageOverlayEntry = OverlayEntry(
      builder:
          (context) => AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: ImagePreviewOverlay(
                  pickedImage: _pickedImage!,
                  onSend: () async {
                    setState(() => _isSendingImage = true);
                    await Future.delayed(
                      const Duration(milliseconds: 100),
                    ); // Force UI update
                    await sendImage(_pickedImage!.path);
                    setState(() => _isSendingImage = false);
                    await Future.delayed(
                      const Duration(milliseconds: 400),
                    ); // Keep spinner visible
                    _removeImageOverlay();
                  },
                  onRemove: () {
                    setState(() {
                      _pickedImage = null;
                    });
                    _removeImageOverlay();
                  },
                  onPickAnother: () async {
                    final pickedFile = await pickImageFromGallery();
                    if (pickedFile != null) {
                      setState(() {
                        _pickedImage = pickedFile;
                      });
                      _removeImageOverlay();
                      _showImagePreviewOverlay();
                    }
                  },
                  isSending: _isSendingImage,
                ),
              ),
            ),
          ),
    );
    Overlay.of(context, rootOverlay: true).insert(_imageOverlayEntry!);
  }

  void _removeImageOverlay() {
    _imageOverlayEntry?.remove();
    _imageOverlayEntry = null;
  }

  Future<void> _sendMessage() async {
    print('MessageInput: _sendMessage called');

    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : null;

    if (currentUserId != null && _controller.text.isNotEmpty) {
      final message = {
        'chatId': widget.chatId,
        'senderId': currentUserId,
        'type': 'text',
        'content': _controller.text.trim(),
        'mediaUrl': '',
      };
      print('MessageInput: Sending text message via Socket.IO: $message');
      socketService.sendMessage(message);
      _controller.clear();
      FocusScope.of(context).unfocus();
    } else {
      print(
        'MessageInput: Cannot send message - userId: $currentUserId, text empty: ${_controller.text.isEmpty}',
      );
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      await _recorderController?.stop();
      setState(() => _isRecording = false);
      _stopRecordTimer();
      _removeRecordingOverlay();
    } else {
      bool hasPermission = await _audioRecorder.hasPermission();
      if (hasPermission) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
        const config = RecordConfig(
          encoder: AudioEncoder.aacLc, // AAC codec
          bitRate: 128000, // 128 kbps
          sampleRate: 44100, // 44.1 kHz
          numChannels: 1, // Mono
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        );

        try {
          await _audioRecorder.start(config, path: filePath);
          _recorderController?.reset();
          _recorderController?.record();
          setState(() => _isRecording = true);
          _startRecordTimer();
          _showRecordingOverlay();
        } catch (e) {
          print('Error starting recording: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start recording: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
    }
  }

  void _cancelRecording() async {
    await _audioRecorder.stop();
    await _recorderController?.stop();
    setState(() => _isRecording = false);
    _stopRecordTimer();
    _removeRecordingOverlay();
  }

  Future<void> sendAudio(String mediaPath) async {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : null;
    if (currentUserId != null) {
      try {
        // Convert file to base64
        final file = File(mediaPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();

          // Check file size (max 10MB for audio)
          const maxSize = 10 * 1024 * 1024; // 10MB
          if (bytes.length > maxSize) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Audio file is too large. Maximum size is 10MB.'),
              ),
            );
            return;
          }

          final base64String = base64Encode(bytes);
          // Use generic audio MIME type for better compatibility
          final dataUrl = 'data:audio/mpeg;base64,$base64String';

          // Send via Socket.IO for real-time updates
          final message = {
            'chatId': widget.chatId,
            'senderId': currentUserId,
            'type': 'audio',
            'mediaUrl': dataUrl,
          };
          print(
            'MessageInput: Sending audio message via Socket.IO (${bytes.length} bytes)',
          );
          print('MessageInput: Audio message data: $message');
          socketService.sendMessage(message);
        } else {
          print('MessageInput: Audio file not found: $mediaPath');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Audio file not found')));
        }
      } catch (e) {
        print('MessageInput: Error sending audio: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send audio: $e')));
      }
    }
  }

  Future<void> sendImage(String imagePath) async {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : null;
    if (currentUserId != null) {
      try {
        // Convert file to base64
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();

          // Check file size (max 5MB for images)
          const maxSize = 5 * 1024 * 1024; // 5MB
          if (bytes.length > maxSize) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image file is too large. Maximum size is 5MB.'),
              ),
            );
            return;
          }

          final base64String = base64Encode(bytes);

          // Detect MIME type from file extension
          String mimeType = 'image/jpeg'; // default
          final extension = imagePath.split('.').last.toLowerCase();
          switch (extension) {
            case 'png':
              mimeType = 'image/png';
              break;
            case 'gif':
              mimeType = 'image/gif';
              break;
            case 'webp':
              mimeType = 'image/webp';
              break;
            case 'jpg':
            case 'jpeg':
            default:
              mimeType = 'image/jpeg';
              break;
          }

          final dataUrl = 'data:$mimeType;base64,$base64String';

          // Send via Socket.IO for real-time updates
          final message = {
            'chatId': widget.chatId,
            'senderId': currentUserId,
            'type': 'image',
            'mediaUrl': dataUrl,
          };
          print(
            'MessageInput: Sending image message via Socket.IO (${bytes.length} bytes, $mimeType)',
          );
          print('MessageInput: Image message data: $message');
          socketService.sendMessage(message);

          // Reset picked image state after sending
          setState(() {
            _pickedImage = null;
          });
        } else {
          print('MessageInput: Image file not found: $imagePath');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image file not found')));
        }
      } catch (e) {
        print('MessageInput: Error sending image: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
      }
    }
  }

  void _onTextChange() {
    setState(() {});
  }

  Future<void> _loadWaveform() async {
    if (_recordedAudioPath != null && _playerController != null) {
      try {
        print('Loading waveform for: $_recordedAudioPath');

        await _playerController!.stopPlayer();

        await _playerController!.preparePlayer(
          path: _recordedAudioPath!,
          shouldExtractWaveform: true,
        );

        await Future.delayed(const Duration(milliseconds: 800));

        print(
          'Waveform loaded: ${_playerController!.waveformData.length} data points',
        );

        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('Error loading waveform: $e');
      }
    }
  }

  Future<void> _showAudioPreviewOverlay() async {
    if (_recordedAudioPath == null) return;

    _removeAudioOverlay();

    // Load waveform trước khi show overlay
    await _loadWaveform();

    _audioOverlayEntry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setStateSB) => AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: AudioPreviewOverlay(
                      audioPath: _recordedAudioPath!,
                      playerController: _playerController!,
                      audioDuration: _audioDuration,
                      recordDuration: _recordDuration,
                      onSend: () async {
                        await _playerController!.stopPlayer();
                        await sendAudio(_recordedAudioPath!);
                        setState(() {
                          _recordedAudioPath = null;
                          _audioDuration = null;
                          _isPlaying = false;
                        });
                        _removeAudioOverlay();
                      },
                      onDelete: () async {
                        await _playerController!.stopPlayer();
                        setState(() {
                          _recordedAudioPath = null;
                          _audioDuration = null;
                          _isPlaying = false;
                        });
                        _removeAudioOverlay();
                      },
                      formatDuration: formatDuration,
                      onComplete: () async {
                        await _playerController!.seekTo(0);
                        setState(() => _isPlaying = false);
                        setStateSB(() {});
                      },
                    ),
                  ),
                ),
              ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_audioOverlayEntry!);
  }

  void _pauseRecording() async {
    print('MessageInput: _pauseRecording called');
    try {
      final path = await _audioRecorder.stop();
      await _recorderController?.stop();

      Duration? duration;
      if (path != null) {
        print('MessageInput: Audio recorded to: $path');
        final player = ap.AudioPlayer();
        await player.setSource(ap.DeviceFileSource(path));
        duration = await player.getDuration();
        await player.dispose();
        print('MessageInput: Audio duration: $duration');
      } else {
        print('MessageInput: No audio path returned from recorder');
      }

      setState(() {
        _isRecording = false;
        _stopRecordTimer();
        _recordedAudioPath = path;
        _audioDuration = duration;
        _isPlaying = false;
      });

      _removeRecordingOverlay();

      if (_recordedAudioPath != null) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (File(_recordedAudioPath!).existsSync()) {
          await _showAudioPreviewOverlay();
        } else {
          print('Audio file not found for preview');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio file not found for preview')),
          );
        }
      }
    } catch (e) {
      print('MessageInput: Error in _pauseRecording: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
    }
  }

  void _removeAudioOverlay() {
    _audioOverlayEntry?.remove();
    _audioOverlayEntry = null;
  }

  void _showRecordingOverlay() {
    _recordingOverlayEntry = OverlayEntry(
      builder:
          (context) => AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: RecordingOverlay(
                  formatDuration: formatDuration,
                  onPause: () {
                    _pauseRecording();
                    _removeRecordingOverlay();
                  },
                  onCancel: () {
                    _cancelRecording();
                    _removeRecordingOverlay();
                  },
                  recorderController: _recorderController!,
                ),
              ),
            ),
          ),
    );
    Overlay.of(context, rootOverlay: true).insert(_recordingOverlayEntry!);
  }

  void _removeRecordingOverlay() {
    _recordingOverlayEntry?.remove();
    _recordingOverlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main input row: camera, mic, textfield, send button
              Opacity(
                opacity:
                    (_pickedImage != null ||
                            _recordedAudioPath != null ||
                            _isRecording)
                        ? 0.3
                        : 1.0,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            width: 2,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Pick image button
                          IconButton(
                            icon: const Icon(CupertinoIcons.camera_fill),
                            onPressed: _pickImage,
                          ),
                          // Record audio button
                          IconButton(
                            icon: Icon(
                              _isRecording
                                  ? CupertinoIcons.pause_fill
                                  : CupertinoIcons.mic_fill,
                            ),
                            color: _isRecording ? Colors.red : null,
                            onPressed: _toggleRecording,
                          ),
                        ],
                      ),
                    ),
                    // Text input
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: TextField(
                          controller: _controller,
                          onChanged: (_) => _onTextChange(),
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    // Send button
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 24),
                      child: GlowingActionButton(
                        color: AppColors.secondary,
                        icon: Icons.send_rounded,
                        size: 46,
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
