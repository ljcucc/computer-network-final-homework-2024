import 'package:app/widgets/animated_image/animated_image.dart';
import 'package:app/widgets/connection_config/connection_config.dart';
import 'package:app/widgets/rtsp_button_group/rtsp_button_group.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MjpgStreamingPage extends StatelessWidget {
  const MjpgStreamingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mjpg Streaming"),
      ),
      body: const SafeArea(
        minimum: EdgeInsets.all(24),
        child: Column(children: [
          ConnectionConfigWidget(),
          Gap(16),
          Expanded(
            child: AnimatedImageWidget(),
          ),
          Gap(16),
          RtspButtonGroup(),
        ]),
      ),
    );
  }
}
