import "dart:async";

import "package:flutter/material.dart";
import "package:fridgital/shared/classes/constant_gradient.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/side_button.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicScreenWidget(
      child: MouseSingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeTitle(),
            for (int i = 0; i < 10; ++i) const NearingExpiry(),
          ],
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
  late final PageController pageController;
  late final ValueNotifier<int?> activePage;

  @override
  void initState() {
    super.initState();

    pageController = new PageController(initialPage: 1e9.toInt(), viewportFraction: 0.75);
    activePage = new ValueNotifier<int?>(null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      activePage.value = pageController.page!.round();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    activePage.dispose();

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
                    var tabInformation = RouteState.of(context);

                    tabInformation.toggleSecondLayer();
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: NotificationListener<Notification>(
            onNotification: (notification) {
              if (notification case ScrollNotification(depth: <= 0)) {
                activePage.value = pageController.page!.round();

                return true;
              }

              if (notification case ChangePageNotification(:var index)) {
                unawaited(
                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutQuart,
                  ),
                );

                return true;
              }

              return false;
            },
            child: SizedBox(
              height: 150,
              child: MouseScroll(
                controller: pageController,
                builder: (context, controller, physics) {
                  return PageView.builder(
                    controller: controller,
                    physics: physics,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: NearingExpiryTile(
                          index: index,
                          activePage: activePage,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NearingExpiryTile extends StatelessWidget {
  const NearingExpiryTile({
    required this.index,
    required this.activePage,
    super.key,
  });

  final int index;
  final ValueNotifier<int?> activePage;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: activePage,
      builder: (context, child) {
        if (activePage.value case int value when value != index) {
          return MouseRegion(cursor: SystemMouseCursors.click, child: child);
        }
        return child!;
      },
      child: GestureDetector(
        onTap: () async {
          if (activePage.value case int page when page != index && context.mounted) {
            ChangePageNotification(index).dispatch(context);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColoredBox(
            color: const Color(0xff92a8d1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text("${index % 5}"),
                ),
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(colors: [Colors.transparent, Colors.black])
                        .createShader(Offset.zero & rect.size);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return ConstantGradient(color: const Color(0xff92a8d1)).createShader(Offset.zero & rect.size);
                    },
                    blendMode: BlendMode.color,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Image.asset(
                        "assets/images/pesto.jpg",
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChangePageNotification extends Notification {
  const ChangePageNotification(this.index);

  final int index;
}
