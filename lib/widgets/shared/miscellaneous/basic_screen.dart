import "package:flutter/widgets.dart";

class BasicScreenWidget extends StatelessWidget {
  const BasicScreenWidget({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFAE3),
            Color(0xFFF7CAC9),
          ],
        ),
      ),
      child: SafeArea(
        child: child,
      ),
    );
  }
}
