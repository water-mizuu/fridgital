import "package:flutter/material.dart";
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            scrollPercentage = scrollController.offset / _threshold;
          });
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
    var theme = Theme.of(context);

    return Scaffold(
      body: FractionallySizedBox(
        widthFactor: 1.0,
        child: BasicScreenWidget(
          child: Scrollbar(
            controller: scrollController,
            child: MouseSingleChildScrollView(
              padding: const EdgeInsets.all(64.0),
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < 36; ++i)
                      Text(
                        "One-pot Pesto",
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 42.0),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
