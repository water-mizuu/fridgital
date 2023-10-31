import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";

class SideButton extends StatelessWidget {
  const SideButton({
    required this.onTap,
    super.key,
  });

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleY: 0.75,
      child: Transform.translate(
        offset: const Offset(0, -12.0),
        child: GestureDetector(
          onTap: onTap,
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Opacity(
              opacity: 0.5,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 22.0,
                color: FigmaColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
