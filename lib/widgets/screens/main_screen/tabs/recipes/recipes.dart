import "package:flutter/material.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/recipes/widgets/recipe_tile.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/recipes/widgets/recipe_title.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class Recipes extends StatelessWidget {
  const Recipes({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicScreenWidget(
      child: MouseSingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RecipeTitle(),
            const SizedBox(height: 16.0),
            RecipeTile(
              title: "One-pot pesto",
              ingredients: [for (int i = 0; i < 5; ++i) "ingredient-$i"],
              imageUrl: "assets/images/pesto.jpg",
            ),
          ],
        ),
      ),
    );
  }
}
