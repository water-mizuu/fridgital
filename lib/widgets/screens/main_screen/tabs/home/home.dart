import "package:flutter/material.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home/widgets/home_title.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home/widgets/nearing_expiry/nearing_expiry_display.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home/"
    "widgets/recommended_recipe/recommended_recipe_display.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";
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
            NearingExpiryDisplay(),
            RecommendedRecipeDisplay(),
            shrinkingNavigationOffset,
          ],
        ),
      ),
    );
  }
}
