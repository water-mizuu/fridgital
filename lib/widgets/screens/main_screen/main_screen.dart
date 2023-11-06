import "package:flutter/material.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home/home.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/inventory/inventory.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/recipes/recipes.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/to_buy/to_buy.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final TabController tabController;
  late final ValueNotifier<double> latestScrollOffset;

  bool handleNotification(Notification notification) {
    if (notification case ShrinkingNavigationUpdateNotification(:var index)) {
      tabController.animateTo(index);

      return true;
    }

    if (!tabController.indexIsChanging) {
      if (notification case ScrollUpdateNotification(:var scrollDelta?)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          latestScrollOffset.value = scrollDelta;
        });

        return false;
      }
    }

    return false;
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this, initialIndex: 2);
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
    return Scaffold(
      body: FractionallySizedBox(
        widthFactor: 1.0,
        child: NotificationListener<Notification>(
          onNotification: handleNotification,
          child: Stack(
            children: [
              TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [Recipes(), Inventory(), Home(), ToBuy()],
              ),
              Positioned(
                bottom: 0.0,
                child: ShrinkingNavigation(
                  controller: tabController,
                  latestScrollOffset: latestScrollOffset,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
