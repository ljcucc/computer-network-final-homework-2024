import 'package:app/data/rtsp_provider.dart';
import 'package:app/utils/transcode_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TranscodeVideoPlayer();
  }
}
