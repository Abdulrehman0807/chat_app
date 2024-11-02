import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerSCreen extends StatefulWidget {
  String? videoUrl;
  VideoPlayerSCreen({super.key, this.videoUrl});

  @override
  State<VideoPlayerSCreen> createState() => _VideoPlayerSCreenState();
}

class _VideoPlayerSCreenState extends State<VideoPlayerSCreen> {
  VideoPlayerController? videoPlayerController;
  Future<void>? initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        widget.videoUrl!,
      ),
    );

    initializeVideoPlayerFuture = videoPlayerController!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
                return AspectRatio(
                  aspectRatio: videoPlayerController!.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(videoPlayerController!),
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  // If the video is playing, pause it.
                  if (videoPlayerController!.value.isPlaying) {
                    videoPlayerController!.pause();
                  } else {
                    // If the video is paused, play it.
                    videoPlayerController!.play();
                  }
                });
              },
              child: Icon(
                videoPlayerController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
