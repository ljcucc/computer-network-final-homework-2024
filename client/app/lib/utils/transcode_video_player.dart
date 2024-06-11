library transcode_video_player;

import 'dart:convert';
import 'dart:math';

import 'package:app/utils/provider_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart';
import 'package:socket_rtsp/socket_rtsp.dart';

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

  Random random = new Random();

  late final server = HLSServer(
    filename: 'filename',
    resolveM3u8: () async {
      print(">>> fetching m3u8");
      final client = RtspClient(
        serverAddr: '127.0.0.1',
        serverPort: 8080,
        rtpPort: random.nextInt(10000) + 1000,
        fileName: '../hls/filename.m3u8',
      );
      await client.connect();
      while (client.rtspSocket == null) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      client.sendRtspRequest(RtspRequest.setup);
      while (client.state != RtspState.ready) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      final joiner = ChunkJoiner(client.frameStream);
      client.sendRtspRequest(RtspRequest.play);
      await joiner.join();
      client.sendRtspRequest(RtspRequest.teardown);
      print("<<< fetching m3u8");
      return utf8.decode(joiner.joinedData);
    },
    resolveTs: (i) async {
      print(">>> fetching $i.ts");
      final client = RtspClient(
        serverAddr: '127.0.0.1',
        serverPort: 8080,
        rtpPort: random.nextInt(10000) + 1000,
        fileName: '../hls/filename${i.toString()}.ts',
      );
      await client.connect();
      while (client.rtspSocket == null) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      client.sendRtspRequest(RtspRequest.setup);
      while (client.state != RtspState.ready) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      final joiner = ChunkJoiner(client.frameStream);
      client.sendRtspRequest(RtspRequest.play);
      await joiner.join();
      client.sendRtspRequest(RtspRequest.teardown);
      print("<<< fetching $i.ts");
      return joiner.joinedData;
    },
  );

  @override
  void initState() {
    super.initState();
    server.start(8090);
    _startVideoStream();
  }

  _startVideoStream() async {
    player.open(Media('http://localhost:8090/filename.m3u8'));
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
