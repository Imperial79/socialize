import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class ChewiePlayer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  ChewiePlayer({
    required this.videoPlayerController,
    required this.looping,
  });

  @override
  State<ChewiePlayer> createState() => _ChewiePlayerState();
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: widget.videoPlayerController.value.aspectRatio,
      // aspectRatio: 2,
      autoInitialize: true,
      looping: widget.looping,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            'Cannot Play Video',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController!,
    );
  }

  @override
  void dispose() {
    super.dispose();

    widget.videoPlayerController.dispose();
    _chewieController!.dispose();
  }
}
