import 'package:app/widgets/animated_image/animated_image.dart';
import 'package:app/widgets/animated_image/animated_image_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonGroups =
        Consumer<AnimatedImageController>(builder: (context, value, child) {
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

    return SafeArea(
      minimum: const EdgeInsets.all(24),
      child: Column(children: [
        const Expanded(
          child: AnimatedImageWidget(),
        ),
        const Gap(8),
        buttonGroups,
      ]),
    );
  }
}
