import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final bool autoPlay;
  final bool loop;
  final bool showControls;

  const VideoPlayerWidget({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.autoPlay = false,
    this.loop = false,
    this.showControls = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  bool _isInitialized = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.videoUrl != null) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else if (widget.videoFile != null) {
      _videoPlayerController = VideoPlayerController.file(widget.videoFile!);
    } else {
      return;
    }

    try {
      await _videoPlayerController.initialize();
      _videoPlayerController.setLooping(widget.loop);
      _videoPlayerController.setVolume(_isMuted ? 0.0 : 1.0);
      
      // ONLY play if autoPlay is true (synced with Reels tab visibility)
      if (widget.autoPlay) {
        _videoPlayerController.play();
      } else {
        _videoPlayerController.pause();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized) {
      if (widget.autoPlay && !oldWidget.autoPlay) {
        _videoPlayerController.play();
      } else if (!widget.autoPlay && oldWidget.autoPlay) {
        _videoPlayerController.pause();
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.pause();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isMuted = !_isMuted;
          _videoPlayerController.setVolume(_isMuted ? 0.0 : 1.0);
        });
      },
      onLongPressStart: (_) => _videoPlayerController.pause(),
      onLongPressEnd: (_) => _videoPlayerController.play(),
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Robust rendering stack to fix diagonal tearing/glitches
            SizedBox.expand(
              child: ClipRect(
                clipBehavior: Clip.antiAlias,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoPlayerController.value.size.width,
                    height: _videoPlayerController.value.size.height,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                ),
              ),
            ),
            
            // Mute/Unmute Visual Indicator (Tap Feedback)
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isMuted ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            if (!_videoPlayerController.value.isPlaying)
              const Icon(
                Icons.play_arrow_rounded,
                size: 80,
                color: Colors.white38,
              ),

            // Instagram-style progress bar at the very bottom
            if (widget.showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 2,
                  child: VideoProgressIndicator(
                    _videoPlayerController,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
