import 'dart:typed_data';

import 'package:app/data/rtsp_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedImageWidget extends StatelessWidget {
  const AnimatedImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RtspProvider>(
        builder: (BuildContext context, RtspProvider value, Widget? child) {
      Widget imageStream = value.client == null
          ? Container()
          : StreamBuilder<Uint8List>(
              stream: value.client?.frameStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  print("dont have data");
                  return Container();
                }
                print("have data");
                return Image.memory(
                  fit: BoxFit.cover,
                  snapshot.requireData,
                  gaplessPlayback: true,
                );
              },
            );

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        child: value.isSetup ? imageStream : Container(),
      );
    });
  }
}
