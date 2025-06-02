import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

class AudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final String messageId;
  final Function(String?) onPlayingChanged;
  final String? currentlyPlayingMessageId;

  const AudioMessageWidget({
    super.key,
    required this.audioUrl,
    required this.messageId,
    required this.onPlayingChanged,
    this.currentlyPlayingMessageId,
  });

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading =
              state == PlayerState.playing && _position == Duration.zero;
        });

        // Notify parent widget about playing state
        if (state == PlayerState.playing) {
          widget.onPlayingChanged(widget.messageId);
        } else if (state == PlayerState.stopped ||
            state == PlayerState.completed) {
          widget.onPlayingChanged(null);
        }
      }
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        widget.onPlayingChanged(null);
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });

      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Stop other audio if playing
        if (widget.currentlyPlayingMessageId != null &&
            widget.currentlyPlayingMessageId != widget.messageId) {
          // This will be handled by the parent widget
        }

        setState(() {
          _isLoading = true;
        });

        await _audioPlayer.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load audio: ${e.toString()}';
        _isLoading = false;
        _isPlaying = false;
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _position = Duration.zero;
    });
    await _togglePlayPause();
  }

  Future<void> _seekTo(double value) async {
    final position = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void didUpdateWidget(AudioMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Stop playing if another audio started
    if (widget.currentlyPlayingMessageId != widget.messageId && _isPlaying) {
      _audioPlayer.pause();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentlyPlaying =
        widget.currentlyPlayingMessageId == widget.messageId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Play/Pause Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                  onPressed: _hasError ? null : _togglePlayPause,
                ),
              ),
              const SizedBox(width: 12),

              // Audio Info and Controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      children: [
                        Icon(
                          Icons.audiotrack,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Audio Message',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        if (_hasError) ...[
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.accent,
                            ),
                          ),
                        ] else if (isCurrentlyPlaying && _isPlaying) ...[
                          Icon(
                            Icons.volume_up_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Progress Bar and Time
                    if (!_hasError) ...[
                      Row(
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12,
                                ),
                                activeTrackColor: AppColors.secondary,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: AppColors.secondary,
                                overlayColor: AppColors.secondary.withOpacity(
                                  0.2,
                                ),
                              ),
                              child: Slider(
                                value:
                                    _duration.inMilliseconds > 0
                                        ? _position.inMilliseconds /
                                            _duration.inMilliseconds
                                        : 0.0,
                                onChanged:
                                    _duration.inMilliseconds > 0
                                        ? _seekTo
                                        : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Error Message and Retry
                    if (_hasError) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: TextStyle(fontSize: 12, color: AppColors.accent),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _retry,
                          icon: Icon(
                            Icons.refresh,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          label: Text(
                            'Retry',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
