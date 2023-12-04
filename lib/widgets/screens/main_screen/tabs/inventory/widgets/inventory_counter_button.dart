import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";

class InventoryCounterButton extends HookWidget {
  const InventoryCounterButton({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClickableWidget(
        onTap: onTap,
        child: Icon(icon, color: const Color(0xff807171)),
      ),
    );
  }
}
