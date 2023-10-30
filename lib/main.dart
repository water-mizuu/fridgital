import "package:flutter/material.dart";
import "package:fridgital/extensions/times.dart";
import "package:mouse_scroll/mouse_scroll.dart";

void main() {
  runApp(const MyApp());
}

const colors = (
  textDark: Color(0xFF2D2020),
  whiteAccent: Color(0xFFFFFDF6),
  pinkAccent: Color(0xFFB18887),
);

/// INHERITED WIDGETS

class RouteState extends InheritedWidget {
  const RouteState({
    required this.activePage,
    required this.moveTo,
    required super.child,
    super.key,
  });

  final Pages activePage;
  final void Function(Pages) moveTo;

  static RouteState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RouteState>();
  }

  static RouteState of(BuildContext context) {
    var state = maybeOf(context);
    assert(state != null, "No RouteState found in context");

    return state!;
  }

  @override
  bool updateShouldNotify(covariant RouteState oldWidget) => oldWidget.activePage != activePage;
}

enum Pages { recipes, inventory, home, toBuy }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final ThemeData themeData = ThemeData(
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
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    ),
    useMaterial3: true,
  );

  Pages activePage = Pages.home;

  void Function() changePage(Pages page) {
    return () {
      setState(() {
        activePage = page;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return RouteState(
      activePage: activePage,
      moveTo: changePage,
      child: MaterialApp(
        theme: themeData,
        home: Navigator(
          pages: const [
            MaterialPage(
              child: MainScreen(
                children: [
                  HomeTab(),
                  OnePotPestoTab(),
                ],
              ),
            ),
          ],
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({required this.children, super.key});

  final List<Widget> children;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final TabController tabController;
  late final ValueNotifier<double> latestScrollOffset;

  bool handleNotification(Notification notification) {
    switch (notification) {
      case ShrinkingNavigationUpdateNotification(:var index):
        tabController.animateTo(index);

        return true;
      case ScrollUpdateNotification(:var scrollDelta?) when !tabController.indexIsChanging:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          latestScrollOffset.value = scrollDelta;
        });

        return false;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: widget.children.length, vsync: this);
    latestScrollOffset = ValueNotifier<double>(0.0);
  }

  @override
  void dispose() {
    tabController.dispose();
    latestScrollOffset.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<Notification>(
      onNotification: handleNotification,
      child: Scaffold(
        body: Stack(
          children: [
            TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: widget.children,
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: ShrinkingNavigation(latestScrollOffset: latestScrollOffset),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicScreenWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeTitle(),
          for (void _ in 20.times) const NearingExpiry(),
        ],
      ),
    );
  }
}

class OnePotPestoTab extends StatelessWidget {
  const OnePotPestoTab({super.key});

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
                Text("One-pot Pesto".toUpperCase(), style: theme.textTheme.titleLarge),
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

/// MISC WIDGETS

class ShrinkingNavigation extends StatefulWidget {
  const ShrinkingNavigation({required this.latestScrollOffset, super.key});

  final ValueNotifier<double> latestScrollOffset;

  @override
  State<ShrinkingNavigation> createState() => _ShrinkingNavigationState();
}

class _ShrinkingNavigationState extends State<ShrinkingNavigation> {
  bool isRetracted = false;

  void updateRetracted() {
    setState(() => isRetracted = widget.latestScrollOffset.value > 0.0);
  }

  void toggleRetracted() {
    setState(() => isRetracted = !isRetracted);
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
    const margin = 20.0;
    const padding = 8.0;

    var width = MediaQuery.sizeOf(context).width - margin * 2 - padding * 2;
    var arbitraryRetracted = 32.0 + padding * 2;

    return Padding(
      padding: const EdgeInsets.all(margin),
      child: AnimatedContainer(
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: colors.whiteAccent,
          borderRadius: BorderRadius.circular(256.0),
        ),
        duration: const Duration(milliseconds: 125),
        width: isRetracted ? arbitraryRetracted : width,
        curve: Curves.fastOutSlowIn,
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
                      onTap: toggleRetracted,
                      child: Icon(Icons.menu, size: 32.0, color: colors.pinkAccent),
                    ),
                  )
                else ...[
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: toggleRetracted,
                      child: Icon(Icons.menu, size: 32.0, color: colors.pinkAccent),
                    ),
                  ),
                  for (int i in 4.times.map((v) => 3 - v))
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          ShrinkingNavigationUpdateNotification(i).dispatch(context);
                        },
                        child: SizedBox(height: 32.0, child: Center(child: Text("$i"))),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeTitle extends StatelessWidget {
  const HomeTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

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
    super.key,
  });

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
    var theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("nearing expiry", style: theme.textTheme.titleMedium),
                const SizedBox(width: 8.0),
                SideButton(
                  onTap: () {
                    var state = RouteState.of(context);

                    state.moveTo(Pages.recipes);
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

/// NOTIFICATIONS

sealed class ShrinkingNavigationNotification extends Notification {}

class ShrinkingNavigationUpdateNotification extends ShrinkingNavigationNotification {
  ShrinkingNavigationUpdateNotification(this.index);

  final int index;
}
