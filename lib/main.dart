import "package:flutter/material.dart";
import "package:fridgital/extensions/times.dart";
import "package:mouse_scroll/mouse_scroll.dart";

void main() {
  runApp(const MyApp());
}

// ignore: always_specify_types
const colors = (
  textDark: Color(0xFF2D2020),
  whiteAccent: Color(0xFFFFFDF6),
  pinkAccent: Color(0xFFB18887),
);

enum Pages {
  home,
  recipes,
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Pages activePage = Pages.home;

  void Function() changePage(Pages page) {
    return () {
      setState(() {
        activePage = page;
      });
    };
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontFamily: "Nunito",
            fontSize: 45.0,
            fontWeight: FontWeight.w900,
            color: colors.textDark,
          ),
          titleMedium: TextStyle(
            fontFamily: "Nunito",
            fontSize: 30.0,
            fontWeight: FontWeight.w800,
            color: colors.textDark,
          ),
          displayLarge: TextStyle(
            fontFamily: "Nunito",
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
            color: colors.textDark,
          ),
        ),
        useMaterial3: true,
      ),
      home: Navigator(
        pages: [
          switch (activePage) {
            Pages.home => const MaterialPage(child: HomeScreen()),
            Pages.recipes => const MaterialPage(child: HomeScreen()),
          },
        ],
        onPopPage: (route, result) {
          return route.didPop(result);
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<double> latestScrollOffset = ValueNotifier(0.0);
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    latestScrollOffset.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        switch (notification) {
          case ScrollUpdateNotification(:double scrollDelta):
            latestScrollOffset.value = scrollDelta;
        }
        return false;
      },
      child: Scaffold(
        body: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
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
                  child: Stack(
                    children: [
                      MouseSingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeTitle(theme: theme),
                            for (void _ in 20.times) NearingExpiry(theme: theme),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        child: ShrinkingNavigation(latestScrollOffset: latestScrollOffset),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShrinkingNavigation extends StatefulWidget {
  const ShrinkingNavigation({
    required this.latestScrollOffset,
    super.key,
  });

  final ValueNotifier<double> latestScrollOffset;

  @override
  State<ShrinkingNavigation> createState() => _ShrinkingNavigationState();
}

class _ShrinkingNavigationState extends State<ShrinkingNavigation> {
  bool isRetracted = false;

  void updateRetracted() {
    setState(() => isRetracted = widget.latestScrollOffset.value > 0.0);
  }

  @override
  void initState() {
    super.initState();

    widget.latestScrollOffset.addListener(updateRetracted);
  }

  @override
  void dispose() {
    widget.latestScrollOffset.removeListener(updateRetracted);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width - 20.0 * 2 - 8.0 * 2;
    var arbitraryRetracted = 32.0 + 8.0 * 2;

    return Hero(
      tag: "navigation",
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MouseRegion(
          cursor: isRetracted ? SystemMouseCursors.click : MouseCursor.uncontrolled,
          child: GestureDetector(
            onTap: isRetracted ? () => setState(() => isRetracted = false) : null,
            child: AnimatedContainer(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: colors.whiteAccent,
                borderRadius: BorderRadius.circular(256.0),
              ),
              duration: const Duration(milliseconds: 125),
              width: isRetracted ? arbitraryRetracted : width,
              child: UnconstrainedBox(
                constrainedAxis: Axis.vertical,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: width,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (isRetracted)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => isRetracted = !isRetracted);
                            },
                            child: Icon(Icons.menu, size: 32.0, color: colors.pinkAccent),
                          ),
                        ),
                      for (void _ in 4.times) Icon(Icons.menu, size: 32.0, color: colors.pinkAccent),
                    ],
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

class HomeTitle extends StatelessWidget {
  const HomeTitle({
    required this.theme,
    super.key,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello,\n[User]!".toUpperCase(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8.0),
          Text("Let's see what's in store for you!", style: theme.textTheme.displayLarge),
        ],
      ),
    );
  }
}

class NearingExpiry extends StatefulWidget {
  const NearingExpiry({
    required this.theme,
    super.key,
  });

  final ThemeData theme;

  @override
  State<NearingExpiry> createState() => _NearingExpiryState();
}

class _NearingExpiryState extends State<NearingExpiry> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = new ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("nearing expiry", style: widget.theme.textTheme.titleMedium),
                const SizedBox(width: 8.0),
                SideButton(
                  onTap: () {
                    print("You pressed me my brother");
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: UnconstrainedBox(
            clipBehavior: Clip.hardEdge,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = -5; i < 5; ++i)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 32.0),
                      color: const Color(0xff92a8d1),
                      child: Text("${i % 5}"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
        child: GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 22.0,
              color: colors.textDark.withAlpha(127),
            ),
          ),
        ),
      ),
    );
  }
}
