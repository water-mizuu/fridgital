import "package:flutter/widgets.dart";
import "package:mouse_scroll/mouse_scroll.dart";

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
            Color.fromRGBO(255, 250, 227, 1.0),
            Color.fromRGBO(247, 202, 201, 1.0),
          ],
        ),
      ),
      child: SafeArea(
        child: MouseSingleChildScrollView(
          child: child,
        ),
      ),
    );
  }
}
