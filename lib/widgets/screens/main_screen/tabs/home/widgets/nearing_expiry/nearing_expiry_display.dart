import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/hooks/use_post_render.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home/notifications.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home/widgets/nearing_expiry/nearing_expiry_tile.dart";
import "package:fridgital/widgets/shared/miscellaneous/side_button.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class NearingExpiryDisplay extends HookWidget {
  const NearingExpiryDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    var products = context.select((ProductData data) => data.products);

    var pageController = usePageController(viewportFraction: 0.75);
    var activePage = useValueNotifier<int?>(null);

    usePostRender(() {
      if (!pageController.hasClients) return;

      activePage.value = pageController.page!.round();
    });

    var theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Nearing Expiry", style: theme.textTheme.titleMedium),
                const SizedBox(width: 8.0),
                SideButton(
                  onTap: () {
                    // TODO(water-mizuu): Add button logic.
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8.0),
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
                    duration: 380.ms,
                    curve: Curves.easeOutQuart,
                  ),
                );

                return true;
              }

              return false;
            },
            child: products.isEmpty
                ? SizedBox(
                    height: 150,
                    child: PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: EmptyExpiringTile(),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 150,
                    child: MouseScroll(
                      controller: pageController,
                      builder: (context, controller, physics) => PageView(
                        controller: controller,
                        physics: physics,
                        children: [
                          for (var (index, product) in products.indexed)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: NearingExpiryTile(
                                index: index,
                                product: product,
                                activePage: activePage,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
