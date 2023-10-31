import "package:flutter/material.dart";
import "package:fridgital/shared/extensions/times.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class OnePotPesto extends StatefulWidget {
  const OnePotPesto({required this.index, super.key});

  final int index;

  @override
  State<OnePotPesto> createState() => _OnePotPestoState();
}

class _OnePotPestoState extends State<OnePotPesto> {
  static const double _threshold = 648.0;

  late final ScrollController scrollController;

  final parentKey = GlobalKey();
  final imageRetractedKey = GlobalKey();
  final imageExpandedKey = GlobalKey();

  late double scrollPercentage = scrollController.hasClients ? scrollController.offset / _threshold : 0.0;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          scrollPercentage = scrollController.offset / _threshold;
        });
      });
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const picturePadding = 32.0;
    const pictureSize = 96.0;

    var theme = Theme.of(context);

    return BasicScreenWidget(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: LayoutBuilder(
          key: parentKey,
          builder: (context, constraints) {
            return Stack(
              children: [
                Opacity(
                  opacity: 1.0,
                  child: MouseSingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: constraints.constrainHeight() * 0.5 + picturePadding + pictureSize,
                          child: const ColoredBox(color: Colors.transparent, child: Text("Hi")),
                        ),
                        for (int _ in 36.times)
                          Text("One-pot Pesteee", style: theme.textTheme.titleLarge?.copyWith(fontSize: 42.0)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
