import 'package:app/data/rtsp_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class RtspButtonGroup extends StatelessWidget {
  const RtspButtonGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RtspProvider>(builder: (context, value, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            elevation: 0,
            onPressed: () {
              if (!value.isSetup) {
                print("calling setup()");
                value.setup();
                return;
              }

              print("calling teardown()");
              value.teardown();
            },
            child: Icon(
              value.isSetup
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_off_outlined,
            ),
          ),
          const Gap(8),
          FloatingActionButton(
            elevation: 0,
            onPressed: () {
              if (!value.isPlay) {
                print("calling play()");
                value.play();
                return;
              }

              print("calling pause()");
              value.pause();
            },
            child: Icon(
              value.isPlay ? Icons.pause_outlined : Icons.play_arrow_outlined,
            ),
          )
        ],
      );
    });
  }
}
