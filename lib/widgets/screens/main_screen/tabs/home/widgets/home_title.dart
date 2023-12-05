import "package:flutter/material.dart";

class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key});

  String get greeting {
    switch (DateTime.now().toLocal().hour) {
      case < 12:
        return "Good Morning";
      case < 18:
        return "Good Afternoon";
      case _:
        return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$greeting!".toUpperCase(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8.0),
          Text("Let's see what's in store for you!", style: theme.textTheme.displayLarge),
        ],
      ),
    );
  }
}
