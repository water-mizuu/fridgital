import "package:flutter/material.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";

class OnePotPesto extends StatelessWidget {
  const OnePotPesto({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return BasicScreenWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("One-pot Pesto ($index)".toUpperCase(), style: theme.textTheme.titleLarge),
                const SizedBox(height: 8.0),
                Text("Let's see what's in store for you!", style: theme.textTheme.displayLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
