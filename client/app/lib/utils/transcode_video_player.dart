library transcode_video_player;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart';

class TranscodeVideoPlayer extends StatefulWidget {
  const TranscodeVideoPlayer({super.key});

  @override
  State<TranscodeVideoPlayer> createState() => _TranscodeVideoPlayerState();
}

class _TranscodeVideoPlayerState extends State<TranscodeVideoPlayer> {
// Create a [Player] to control playback.
  late final player = Player();
// Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  // late final StreamingServer providerServer;

  // late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _startVideoStream();
  }

  _startVideoStream() async {
    // final rtsp = Provider.of<RtspProvider>(context, listen: false);
    // providerServer = StreamingServer(widget.stream, rtsp);
    // await providerServer.start("127.0.0.1", 9080);

    // Play a [Media] or [Playlist].
    // print("playing media");
    player.open(Media('http://localhost:8089/filename.m3u8'));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(child: Video(controller: controller)),
        ],
      ),
    );
  }
}
