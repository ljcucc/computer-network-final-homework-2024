import 'package:app/widgets/connection_config/connection_config.dart';
import 'package:app/widgets/rtsp_button_group/rtsp_button_group.dart';
import 'package:app/widgets/video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Mp4StreamingPage extends StatelessWidget {
  const Mp4StreamingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mp4 Streaming"),
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(24),
        child: Column(children: [
          ConnectionConfigWidget(),
          Gap(16),
          Expanded(
            child: VideoPlayerWidget(),
          ),
          Gap(16),
          RtspButtonGroup(),
        ]),
      ),
    );
  }
}
