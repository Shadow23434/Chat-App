import 'dart:async';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class RecordingOverlay extends StatefulWidget {
  final VoidCallback onPause;
  final VoidCallback onCancel;
  final String Function(int) formatDuration;
  final RecorderController recorderController;

  const RecordingOverlay({
    super.key,
    required this.formatDuration,
    required this.onPause,
    required this.onCancel,
    required this.recorderController,
  });

  @override
  State<RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends State<RecordingOverlay> {
  int _recordDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(
                    minWidth: 320,
                    minHeight: 120,
                    maxWidth: 500,
                    maxHeight: 260,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Real waveform
                      SizedBox(
                        width: 180,
                        height: 48,
                        child: AudioWaveforms(
                          size: const Size(180, 48),
                          recorderController: widget.recorderController,
                          enableGesture: false,
                          waveStyle: const WaveStyle(
                            waveColor: AppColors.secondary,
                            extendWaveform: true,
                            showMiddleLine: false,
                            spacing: 4,
                            waveThickness: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.formatDuration(_recordDuration),
                        style: TextStyle(
                          color: AppColors.textFaded,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: AppColors.secondary,
                            elevation: 6,
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: 28,
                              ),
                              tooltip: 'Pause/Stop',
                              onPressed: widget.onPause,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Material(
                            color: Colors.white,
                            elevation: 6,
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 28,
                              ),
                              tooltip: 'Cancel',
                              onPressed: widget.onCancel,
                            ),
                          ),
                        ],
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
}
