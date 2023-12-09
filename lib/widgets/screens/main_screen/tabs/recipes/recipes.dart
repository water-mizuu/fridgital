import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/recipe_data.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/recipes/widgets/recipe_tile.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/recipes/widgets/recipe_title.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class Recipes extends StatelessWidget {
  const Recipes({super.key});
  static final List<Recipe> recipes = [
    Recipe(
      name: "One-pot Pesto",
      directions:
          "Place the pine nuts, basil leaves, garlic, and Parmesan cheese in the bowl of a food processor; season with salt and pepper. Drizzle the olive oil over the mixture. Blend until the pesto is finely ground. Serve over hot pasta.",
      ingredients: [
        "1/2 cup pine nuts",
        "2 cups packed fresh basil leaves",
        "2 cloves garlic, peeled",
        "1/2 cup grated Parmesan cheese",
        "1/2 cup olive oil",
        "salt and pepper to taste",
        "1 (16 ounce) package linguine pasta",
      ],
      imageUrl: "assets/images/pesto.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BasicScreenWidget(
      child: MouseSingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RecipeTitle(),
            const SizedBox(height: 16.0),
            for (var recipe in recipes) RecipeTile(recipe: recipe),
          ],
        ),
      ),
    );
  }
}
