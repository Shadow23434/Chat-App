import 'dart:async';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';

class AudioPreviewOverlay extends StatefulWidget {
  final PlayerController playerController;
  final String audioPath;
  final Duration? audioDuration;
  final int recordDuration;
  final VoidCallback onSend;
  final VoidCallback onDelete;
  final String Function(int) formatDuration;
  final VoidCallback? onComplete;

  const AudioPreviewOverlay({
    super.key,
    required this.playerController,
    required this.audioPath,
    required this.audioDuration,
    required this.recordDuration,
    required this.onSend,
    required this.onDelete,
    required this.formatDuration,
    this.onComplete,
  });

  @override
  State<AudioPreviewOverlay> createState() => _AudioPreviewOverlayState();
}

class _AudioPreviewOverlayState extends State<AudioPreviewOverlay> {
  StreamSubscription<void>? _completionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Check if file exists before preparing player
      if (!File(widget.audioPath).existsSync()) {
        setState(() {
          _isLoading = false;
          _error = 'Audio file not found';
        });
        return;
      }

      // Đảm bảo player được reset trước khi khởi tạo
      await widget.playerController.stopPlayer();

      // Prepare player with audio file
      await widget.playerController.preparePlayer(
        path: widget.audioPath,
        shouldExtractWaveform: true, // Đảm bảo extract waveform
      );

      // Listen for completion
      _completionSub = widget.playerController.onCompletion.listen((_) async {
        if (mounted) {
          print('Audio completed - preparing for replay');
          try {
            // Reset player để có thể replay
            await _resetPlayerForReplay();
            setState(() {
              _isPlaying = false;
            });
            if (widget.onComplete != null) {
              widget.onComplete!();
            }
          } catch (e) {
            print('Error handling completion: $e');
            setState(() {
              _error = 'Playback error: $e';
            });
          }
        }
      });

      // Listen for player state changes
      _playerStateSub = widget.playerController.onPlayerStateChanged.listen((
        state,
      ) {
        if (mounted) {
          print('Player state changed to: $state');
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      // Wait a bit for waveform to be extracted (increase to 800ms)
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying =
              widget.playerController.playerState == PlayerState.playing;
        });
      }
    } catch (e) {
      print('Error initializing player: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _completionSub?.cancel();
    _playerStateSub?.cancel();
    // Đảm bảo stop player khi dispose
    widget.playerController.stopPlayer().catchError((e) {
      print('Error stopping player on dispose: $e');
    });
    super.dispose();
  }

  Future<void> _resetPlayerForReplay() async {
    try {
      print('Resetting player for replay');
      await widget.playerController.stopPlayer();
      await widget.playerController.preparePlayer(
        path: widget.audioPath,
        shouldExtractWaveform: true,
      );
      await widget.playerController.seekTo(0);
      print('Player reset complete');
    } catch (e) {
      print('Error resetting player: $e');
      rethrow;
    }
  }

  void _handlePlayPause() async {
    if (_isLoading) return;

    print(
      'Play/Pause pressed. Current state: ${widget.playerController.playerState}',
    );
    print('audioPath: ${widget.audioPath}');
    print(
      'waveformData.isNotEmpty: ${widget.playerController.waveformData.isNotEmpty}',
    );

    final state = widget.playerController.playerState;

    setState(() {
      _isLoading = true;
      _error = null; // Reset error state
    });

    try {
      if (state == PlayerState.playing) {
        await widget.playerController.pausePlayer();
        print('Paused successfully');
      } else {
        // Nếu đã stopped hoặc chưa được prepare, cần prepare lại
        if (state == PlayerState.stopped ||
            state == PlayerState.initialized ||
            widget.playerController.waveformData.isEmpty) {
          print('Re-preparing player for replay');

          // Stop trước khi prepare lại
          await widget.playerController.stopPlayer();

          await widget.playerController.preparePlayer(
            path: widget.audioPath,
            shouldExtractWaveform: true,
          );
          print('Re-prepared player successfully');

          // Đợi waveform được extract
          int attempts = 0;
          while (widget.playerController.waveformData.isEmpty &&
              attempts < 10) {
            await Future.delayed(const Duration(milliseconds: 100));
            attempts++;
          }

          if (widget.playerController.waveformData.isEmpty) {
            throw Exception('Failed to extract waveform data');
          }
        }

        // Reset về đầu và start
        await widget.playerController.seekTo(0);
        await widget.playerController.startPlayer();
        print('Started playing successfully');
      }
    } catch (e, stack) {
      print('ERROR in _handlePlayPause: $e');
      print('Stack trace: $stack');

      if (mounted) {
        setState(() {
          _error = 'Playback failed: ${e.toString().split(':').last.trim()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width - 32;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    minWidth: 320,
                    minHeight: 120,
                    maxWidth: maxWidth > 500 ? 500 : maxWidth,
                    maxHeight: 260,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade200, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play/Pause button
                      Container(
                        decoration: BoxDecoration(
                          color:
                              _isLoading || _error != null
                                  ? Colors.grey
                                  : Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isLoading
                                ? Icons.hourglass_empty
                                : _error != null
                                ? Icons.error
                                : _isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed:
                              _isLoading || _error != null
                                  ? null
                                  : _handlePlayPause,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Waveform or loading/error state
                      Flexible(
                        child: SizedBox(
                          width: 120,
                          height: 40,
                          child: _buildWaveformWidget(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Audio duration
                      Text(
                        widget.audioDuration != null
                            ? widget.formatDuration(
                              widget.audioDuration!.inSeconds,
                            )
                            : widget.formatDuration(widget.recordDuration),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Send audio button
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.secondary,
                          size: 32,
                        ),
                        tooltip: 'Send audio',
                        onPressed: widget.onSend,
                      ),
                      // Delete audio button
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 32,
                        ),
                        tooltip: 'Delete audio',
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveformWidget() {
    if (_error != null) {
      return const Center(
        child: Text(
          'Error loading audio',
          style: TextStyle(fontSize: 10, color: Colors.red),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
      );
    }

    if (widget.playerController.waveformData.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          // Cho phép click vào waveform để play/pause
          _handlePlayPause();
        },
        child: AudioFileWaveforms(
          size: const Size(120, 40),
          playerController: widget.playerController,
          enableSeekGesture: true,
          waveformType: WaveformType.fitWidth,
          playerWaveStyle: PlayerWaveStyle(
            fixedWaveColor: Colors.blueAccent.withOpacity(0.5),
            liveWaveColor: Colors.blueAccent,
            spacing: 4,
            waveThickness: 2,
          ),
        ),
      );
    }

    return const Center(
      child: Text(
        'No waveform data',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
