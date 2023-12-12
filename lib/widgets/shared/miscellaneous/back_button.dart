import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";

class BackButton extends StatelessWidget {
  const BackButton({
    required this.onTap,
    required this.isBig,
    super.key,
  });

  final void Function() onTap;
  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return !isBig
        ? Transform.scale(
            scaleY: 0.75,
            child: Transform.translate(
              offset: const Offset(0, -12.0),
              child: ClickableWidget(
                onTap: onTap,
                child: const Opacity(
                  opacity: 0.5,
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 22.0,
                    color: FigmaColors.textDark,
                  ),
                ),
              ),
            ),
          )
        : ClickableWidget(
            onTap: onTap,
            child: const Icon(
              Icons.arrow_back_ios,
              size: 22.0,
              color: FigmaColors.textDark,
            ),
          );
  }
}
