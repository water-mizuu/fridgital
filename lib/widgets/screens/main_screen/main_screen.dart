import "package:flutter/material.dart";
import "package:fridgital/widgets/inherited_widgets/tab_information.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";

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
    if (notification case ShrinkingNavigationUpdateNotification(:var index)) {
      setState(() {
        tabController.animateTo(index);
      });

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
