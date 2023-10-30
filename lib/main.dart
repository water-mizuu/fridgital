import "package:flutter/material.dart";
import "package:fridgital/extensions/times.dart";
import "package:fridgital/icons/figma_icon_font.dart";
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

class TabInformation extends InheritedWidget {
  const TabInformation({
    required this.index,
    required this.controller,
    required super.child,
    super.key,
  });

  final TabController controller;
  final int index;

  static TabInformation? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabInformation>();
  }

  static TabInformation of(BuildContext context) {
    var state = maybeOf(context);
    assert(state != null, "No TabInformation found in context");

    return state!;
  }

  @override
  bool updateShouldNotify(covariant TabInformation oldWidget) =>
      oldWidget.index != index || oldWidget.controller != controller;
}

/// MAIN WIDGETS

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
          pages: [
            MaterialPage(
              child: MainScreen(
                children: [
                  const HomeTab(),
                  for (int i in 1.to(4)) OnePotPestoTab(index: i),
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
        setState(() {
          tabController.animateTo(index);
        });

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
    return TabInformation(
      controller: tabController,
      index: tabController.index,
      child: NotificationListener<Notification>(
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
      ),
    );
  }
}

/// TAB WIDGETS

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
  const OnePotPestoTab({required this.index, super.key});

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

/// MISC WIDGETS

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

class ShrinkingNavigation extends StatefulWidget {
  const ShrinkingNavigation({required this.latestScrollOffset, super.key});

  final ValueNotifier<double> latestScrollOffset;

  @override
  State<ShrinkingNavigation> createState() => _ShrinkingNavigationState();
}

/// I need help. I do not know of a better way to do this.
/// It works, but I have to render three layers of the same widget
/// to compute their offsets and then animate them.
///
/// I need tips.
class _ShrinkingNavigationState extends State<ShrinkingNavigation> {
  bool isRetracted = false;
  double? latestWidth;

  void updateRetracted() {
    setState(() {
      isRetracted = widget.latestScrollOffset.value > 0.0;
    });
  }

  void toggleRetracted() {
    setState(() => isRetracted = !isRetracted);
  }

  void updateOffsets() {
    if (parentKey.currentContext?.findRenderObject() case RenderBox parentBox) {
      for (var (i, key) in navigationKeys.indexed) {
        if (key.currentContext?.findRenderObject() case RenderBox box) {
          navigationOffsets[i] = box.localToGlobal(Offset.zero, ancestor: parentBox) +
              Offset(0.0, box.size.height * 1.0625) +
              Offset(box.size.width / 2, 0.0) +
              const Offset(-8.0, 0.0);
        }
      }

      /// Compute the difference.
      if (retractedKey.currentContext?.findRenderObject() case RenderBox retractedBox) {
        if (expandedKey.currentContext?.findRenderObject() case RenderBox expandedBox) {
          retractedOffset = expandedBox.localToGlobal(Offset.zero) - retractedBox.localToGlobal(Offset.zero);
        }
      }

      setState(() => hasComputedOffsets = true);
    }
  }

  @override
  void initState() {
    super.initState();

    widget.latestScrollOffset.addListener(updateRetracted);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateOffsets();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    updateOffsets();
  }

  @override
  void dispose() {
    widget.latestScrollOffset.removeListener(updateRetracted);

    super.dispose();
  }

  bool hasComputedOffsets = false;
  GlobalKey parentKey = GlobalKey();

  GlobalKey retractedKey = GlobalKey();
  GlobalKey expandedKey = GlobalKey();

  Offset retractedOffset = Offset.zero;

  List<Offset> navigationOffsets = List.generate(4, (_) => Offset.zero);
  List<GlobalKey> navigationKeys = List.generate(4, (_) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    const ghostOpacity = 0.00;
    const retractDuration = Duration(milliseconds: 125);

    const iconSize = 32.0;
    const margin = 20.0;
    const padding = 8.0;
    const indicator = (width: 16.0, height: 4.0);

    var activeIndex = TabInformation.of(context).index;
    var width = MediaQuery.sizeOf(context).width - margin * 2 - padding * 2;
    var arbitraryRetracted = iconSize + padding * 2;

    return Padding(
      padding: const EdgeInsets.all(margin),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          /// Evaluated if the navigation is retracted
          IgnorePointer(
            child: Opacity(
              opacity: ghostOpacity,
              child: Container(
                padding: const EdgeInsets.all(padding),
                width: arbitraryRetracted,
                child: UnconstrainedBox(
                  constrainedAxis: Axis.vertical,
                  alignment: Alignment.centerRight,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (void _ in 4.times) const SizedBox(height: iconSize, width: iconSize),
                        Icon(Icons.menu, size: iconSize, color: colors.pinkAccent, key: retractedKey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Evaluated if the navigation is not retracted
          IgnorePointer(
            child: Opacity(
              opacity: ghostOpacity,
              child: Container(
                padding: const EdgeInsets.all(padding),
                width: width,
                child: UnconstrainedBox(
                  key: parentKey,
                  constrainedAxis: Axis.vertical,
                  alignment: Alignment.centerRight,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var i = 0; i < 4; ++i)
                          SizedBox(
                            height: iconSize,
                            width: iconSize,
                            key: navigationKeys[i],
                          ),
                        Icon(null, size: iconSize, key: expandedKey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Actual displayed.
          AnimatedContainer(
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: colors.whiteAccent,
              borderRadius: BorderRadius.circular(256.0),
            ),
            duration: retractDuration,
            width: isRetracted ? arbitraryRetracted : width,
            curve: Curves.fastOutSlowIn,
            child: Stack(
              children: [
                UnconstrainedBox(
                  constrainedAxis: Axis.vertical,
                  alignment: Alignment.centerRight,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i in 4.times)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                ShrinkingNavigationUpdateNotification(i).dispatch(context);
                              },
                              child: Container(
                                height: iconSize,
                                width: iconSize,
                                color: Colors.transparent,
                                child: Center(
                                  child: Icon(
                                    const [
                                      FigmaIconFont.book,
                                      FigmaIconFont.fridge,
                                      Icons.home_outlined,
                                      Icons.list_alt_outlined,
                                    ][i],
                                    size: iconSize,
                                    color: colors.pinkAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        AnimatedTransform.translate(
                          duration: retractDuration,
                          offset: isRetracted ? -retractedOffset : Offset.zero,
                          curve: Curves.fastOutSlowIn,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: toggleRetracted,
                              child: Icon(Icons.menu, size: iconSize, color: colors.pinkAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isRetracted && hasComputedOffsets)
                  AnimatedTransform.translate(
                    offset: navigationOffsets[activeIndex],
                    duration: retractDuration,
                    curve: Curves.fastOutSlowIn,
                    child: Container(
                      width: indicator.width,
                      height: indicator.height,
                      decoration: BoxDecoration(
                        color: colors.pinkAccent,
                        borderRadius: BorderRadius.circular(256.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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

/// HELPER WIDGETS

class AnimatedTransform extends ImplicitlyAnimatedWidget {
  const AnimatedTransform({
    required this.transform,
    required this.child,
    required super.duration,
    super.curve,
    super.key,
    this.origin,
    this.alignment,
    this.transformHitTests = true,
    this.filterQuality,
  });

  AnimatedTransform.translate({
    required Offset offset,
    required super.duration,
    super.curve,
    super.key,
    this.transformHitTests = true,
    this.filterQuality,
    this.child,
  })  : transform = Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        origin = null,
        alignment = null;

  final Matrix4 transform;
  final Offset? origin;
  final AlignmentGeometry? alignment;
  final bool transformHitTests;
  final FilterQuality? filterQuality;
  final Widget? child;

  @override
  AnimatedTransformState createState() => AnimatedTransformState();
}

class AnimatedTransformState extends AnimatedWidgetBaseState<AnimatedTransform> {
  Matrix4Tween? transform;
  Tween<Offset>? origin;
  AlignmentGeometryTween? alignment;

  @override
  Widget build(BuildContext context) {
    var animation = this.animation;

    return Transform(
      transform: transform!.evaluate(animation),
      origin: origin?.evaluate(animation),
      alignment: alignment?.evaluate(animation),
      transformHitTests: widget.transformHitTests,
      filterQuality: widget.filterQuality,
      child: widget.child,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    transform =
        visitor(transform, widget.transform, (dynamic value) => Matrix4Tween(begin: value as Matrix4)) as Matrix4Tween?;
    origin = visitor(origin, widget.origin, (dynamic value) => Tween<Offset>(begin: value as Offset)) as Tween<Offset>?;
    alignment = visitor(
      alignment,
      widget.alignment,
      (dynamic value) => AlignmentGeometryTween(begin: value as AlignmentGeometry),
    ) as AlignmentGeometryTween?;
  }
}

/// NOTIFICATIONS

sealed class ShrinkingNavigationNotification extends Notification {}

class ShrinkingNavigationUpdateNotification extends ShrinkingNavigationNotification {
  ShrinkingNavigationUpdateNotification(this.index);

  final int index;
}
