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

  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: 5, viewportFraction: 0.75);
  }

  @override
  void dispose() {
    pageController.dispose();

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
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              /// Let's not bubble this up any further.
              return true;
            },
            child: SizedBox(
              height: 150,
              child: MouseScroll(
                controller: pageController,
                builder: (context, controller, physics) {
                  return PageView.builder(
                    allowImplicitScrolling: true,
                    controller: controller,
                    physics: physics,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 32.0),
                          color: const Color(0xff92a8d1),
                          child: Text("${index % 5}"),
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
