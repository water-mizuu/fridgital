import "package:flutter/material.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/side_button.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasicScreenWidget(
      child: MouseSingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeTitle(),
            NearingExpiry(),
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
                    print("You pressed me my brother");
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
              }

              /// Let's not bubble this up any further.
              return notification is! ScrollNotification || notification.depth <= 0;
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
                            if (controller.page?.round() case int page when page != index) {
                              await controller.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 380),
                                curve: Curves.easeOutQuart,
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              color: const Color(0xff92a8d1),
                              child: Text("${index % 5}"),
                            ),
                          ),
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
