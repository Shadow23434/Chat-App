import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/chat_app_ui/features/story/story.dart';
import 'package:chat_app/chat_app_ui/utils/helpers.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CreateStoryScreen extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const CreateStoryScreen());

  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _mediaNameController = TextEditingController();
  File? _selectedImage;
  File? _selectedMediaFile;
  String _selectedType = 'image';
  bool _isLoading = false;
  bool _isRecording = false;
  late StoryBloc _storyBloc;
  final AudioRecorder _audioRecorder = AudioRecorder();

  final List<String> _storyTypes = ['image', 'audio', 'video'];

  @override
  void initState() {
    super.initState();
    _storyBloc = StoryBloc(
      getStoriesUseCase: GetStoriesUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      getOwnStoriesUseCase: GetOwnStoriesUseCase(
        repository: StoryRepositoryImpl(
          remoteDataSource: StoryRemoteDataSource(),
        ),
      ),
      createStoryUseCase: CreateStoryUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      likeStoryUseCase: LikeStoryUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      unlikeStoryUseCase: UnlikeStoryUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
      deleteStoryUseCase: DeleteStoryUseCase(
        StoryRepositoryImpl(remoteDataSource: StoryRemoteDataSource()),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _mediaNameController.dispose();
    _audioRecorder.dispose();
    _storyBloc.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // Kiểm tra extension
          final extension = file.extension?.toLowerCase();
          final audioExtensions = ['mp3', 'm4a', 'aac', 'wav', 'flac', 'ogg'];

          if (extension != null && audioExtensions.contains(extension)) {
            setState(() {
              _selectedMediaFile = File(file.path!);
              _mediaNameController.text = file.name;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Error',
                'Please select a valid audio file (mp3, m4a, aac, wav, flac, ogg)',
                Icons.error_outline_rounded,
                Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Error',
          'Failed to pick audio file: $e',
          Icons.error_outline_rounded,
          Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // Kiểm tra extension
          final extension = file.extension?.toLowerCase();
          final videoExtensions = ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv'];

          if (extension != null && videoExtensions.contains(extension)) {
            setState(() {
              _selectedMediaFile = File(file.path!);
              _mediaNameController.text = file.name;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Error',
                'Please select a valid video file (mp4, avi, mov, mkv, wmv, flv)',
                Icons.error_outline_rounded,
                Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Error',
          'Failed to pick video file: $e',
          Icons.error_outline_rounded,
          Colors.red,
        ),
      );
    }
  }

  Future<void> _recordAudio() async {
    if (_isRecording) {
      // Dừng ghi âm
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _selectedMediaFile = File(path);
          _mediaNameController.text =
              'Recorded Audio ${DateTime.now().millisecondsSinceEpoch}';
          _isRecording = false;
        });
      }
    } else {
      // Bắt đầu ghi âm
      if (await _audioRecorder.hasPermission()) {
        final tempDir = Directory.systemTemp;
        final tempPath =
            '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: tempPath,
        );

        setState(() {
          _isRecording = true;
        });

        // Hiển thị dialog ghi âm
        _showRecordingDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Permission Denied',
            'Microphone permission is required to record audio',
            Icons.error_outline_rounded,
            Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _recordVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 10), // Giới hạn 10 phút
    );

    if (video != null) {
      setState(() {
        _selectedMediaFile = File(video.path);
        _mediaNameController.text = video.name;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppColors.secondary,
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.secondary,
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showAudioSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.mic, color: AppColors.secondary),
                  title: const Text('Record Audio'),
                  onTap: () {
                    Navigator.pop(context);
                    _recordAudio();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.audio_file,
                    color: AppColors.secondary,
                  ),
                  title: const Text('Choose from Files'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAudio();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showVideoSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.videocam,
                    color: AppColors.secondary,
                  ),
                  title: const Text('Record Video'),
                  onTap: () {
                    Navigator.pop(context);
                    _recordVideo();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.video_library,
                    color: AppColors.secondary,
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showRecordingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF212121),
            title: const Text(
              'Recording Audio...',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, color: AppColors.secondary, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Tap the button below to stop recording',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _recordAudio(); // Dừng ghi âm
                },
                child: const Text(
                  'Stop Recording',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _createStory() {
    if (_selectedImage == null && _selectedType == 'image') {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Info',
          'Please select an image for image story',
          Icons.info_outline_rounded,
          AppColors.accent,
        ),
      );
      return;
    }

    if (_selectedMediaFile == null &&
        (_selectedType == 'audio' || _selectedType == 'video')) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Info',
          'Please select a $_selectedType file for $_selectedType story',
          Icons.info_outline_rounded,
          AppColors.accent,
        ),
      );
      return;
    }

    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Info',
          'Please add a caption',
          Icons.info_outline_rounded,
          AppColors.accent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Tạo story thông qua StoryBloc
    _storyBloc.add(
      CreateStory(
        caption: _captionController.text.trim(),
        type: _selectedType,
        mediaName:
            _selectedType != 'image' ? _mediaNameController.text.trim() : null,
        mediaUrl:
            _selectedImage != null
                ? _selectedImage!.path
                : _selectedMediaFile?.path,
        backgroundUrl: null, // Có thể thêm background sau
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _storyBloc,
      child: BlocListener<StoryBloc, StoryState>(
        listener: (context, state) {
          if (state is StoryCreated) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Success',
                'Story created successfully!',
                Icons.check_circle_outline_rounded,
                Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is StoryError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Error',
                state.message,
                Icons.error_outline_rounded,
                Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Create Story',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (_selectedImage != null || _selectedType != 'image')
                TextButton(
                  onPressed: _isLoading ? null : _createStory,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story Type Selection
                Card(
                  color: const Color(0xFF212121),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Story Type',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children:
                              _storyTypes.map((type) {
                                final isSelected = _selectedType == type;
                                return ChoiceChip(
                                  label: Text(
                                    type.toUpperCase(),
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.black
                                              : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.secondary,
                                  backgroundColor: const Color(0xFF424242),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedType = type;
                                        if (type != 'image') {
                                          _selectedImage = null;
                                        } else {
                                          _selectedMediaFile = null;
                                        }
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Media Selection
                if (_selectedType == 'image') ...[
                  Card(
                    color: const Color(0xFF212121),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Media',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedImage != null) ...[
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF424242),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF757575),
                                    style: BorderStyle.solid,
                                    width: 2,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Media Name (for audio/video)
                if (_selectedType != 'image') ...[
                  Card(
                    color: const Color(0xFF212121),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Media Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _mediaNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter media name...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Media File Selection (for audio/video)
                  Card(
                    color: const Color(0xFF212121),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedType.toUpperCase()} File',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedMediaFile != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF424242),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF757575),
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedType == 'audio'
                                        ? Icons.audio_file
                                        : Icons.video_file,
                                    color: AppColors.secondary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedMediaFile!.path
                                              .split('/')
                                              .last,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${(_selectedMediaFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedMediaFile = null;
                                        _mediaNameController.clear();
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            GestureDetector(
                              onTap:
                                  _isRecording
                                      ? _recordAudio // Dừng recording nếu đang recording
                                      : (_selectedType == 'audio'
                                          ? _showAudioSourceDialog
                                          : _showVideoSourceDialog),
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF424242),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        _isRecording
                                            ? AppColors.secondary
                                            : const Color(0xFF757575),
                                    style: BorderStyle.solid,
                                    width: _isRecording ? 3 : 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isRecording) ...[
                                      const Icon(
                                        Icons.mic,
                                        color: AppColors.secondary,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Recording...',
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ] else ...[
                                      Icon(
                                        _selectedType == 'audio'
                                            ? Icons.audio_file
                                            : Icons.video_file,
                                        color: Colors.grey,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add ${_selectedType.toUpperCase()}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Caption
                Card(
                  color: const Color(0xFF212121),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Caption',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _captionController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'What\'s on your mind?',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
