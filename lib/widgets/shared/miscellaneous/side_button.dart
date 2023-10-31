import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";

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
        child: const ClickableWidget(
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
    );
  }
}
