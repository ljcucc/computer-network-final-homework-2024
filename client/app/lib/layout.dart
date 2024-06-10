import 'package:app/pages/mjpg_streaming.dart';
import 'package:app/pages/mp4_streaming.dart';
import 'package:app/widgets/animated_image/animated_image_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: ListView(
          children: [
            ListTile(
              title: Text("Mjpg Stream"),
              subtitle: Text("Mjpg Video-only Streaming Test(no audio)"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                            create: (_) => AnimatedImageController()),
                      ],
                      child: const MjpgStreamingPage(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("MPEG-4 Stream"),
              subtitle: Text("MPEG-4 File Streaming"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const Mp4StreamingPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
