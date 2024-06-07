import 'package:client/widgets/animated_image/animated_image_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedImageWidget extends StatelessWidget {
  const AnimatedImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimatedImageController>(builder:
        (BuildContext context, AnimatedImageController value, Widget? child) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        child: value.image != null ? Image.memory(value.image!) : Container(),
      );
    });
  }
}
