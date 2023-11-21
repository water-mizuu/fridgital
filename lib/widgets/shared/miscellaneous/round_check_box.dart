import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";

class RoundCheckBox extends StatelessWidget {
  const RoundCheckBox({
    required this.value,
    required this.color,
    this.onChanged,
    super.key,
  });

  final bool value;
  final Color color;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onChanged;

  static const factors = (
    outer: 0.9,
    middle: 0.75,
    inner: 0.6,
  );

  @override
  Widget build(BuildContext context) {
    return ClickableWidget(
      onTap: () => onChanged?.call(!value),
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: Container(
            width: constraints.maxWidth * factors.outer,
            height: constraints.maxHeight * factors.outer,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Center(
              child: Container(
                width: constraints.maxWidth * factors.middle,
                height: constraints.maxHeight * factors.middle,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: FigmaColors.whiteAccent,
                ),
                child: !value
                    ? const SizedBox()
                    : Center(
                        child: Container(
                          width: constraints.maxWidth * factors.inner,
                          height: constraints.maxHeight * factors.inner,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
