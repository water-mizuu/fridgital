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
        "1 (16 ounce) package penne pasta",
      ],
      imageUrl: "assets/images/pesto.jpg",
    ),
    Recipe(
      name: "Classic Spaghetti Bolognese",
      directions:
          "In a large skillet, brown the ground beef over medium heat. Drain excess fat. Add onion, garlic, carrot, and celery to the skillet. Cook until vegetables are softened. Stir in crushed tomatoes, tomato paste, oregano, basil, salt, and pepper. Simmer for 20-30 minutes. Cook spaghetti according to package instructions. Drain. Serve the Bolognese sauce over cooked spaghetti. Garnish with Parmesan cheese.",
      ingredients: [
        "1lb (450g) ground beef",
        "1 onion, finely chopped",
        "2 cloves garlic, minced",
        "1 carrot, grated",
        "1 celery stalk, finely chopped",
        "1 can (14 oz) crushed tomatoes",
        "2 tbsp tomato paste",
        "1 tsp dried oregano",
        "1 tsp dried basil",
        "Salt and pepper to taste",
        "1 lb (450g) spaghetti",
        "Parmesan cheese for garnish",
      ],
      imageUrl: "assets/images/spaghettibolognese.jpeg",
    ),
    Recipe(
      name: "Lemon Garlic Roast Chicken",
      directions:
          "Preheat oven to 375°F (190°C). Rinse the chicken and pat it dry with paper towels. Place it in a roasting pan. In a small bowl, mix together garlic, olive oil, thyme, rosemary, salt, and pepper. Rub the garlic mixture all over the chicken, including under the skin. Place lemon slices inside the chicken cavity. Roast the chicken in the preheated oven for about 1.5 to 2 hours or until the internal temperature reaches 165°F (74°C). Let the chicken rest for 10 minutes before carving.",
      ingredients: [
        "1 whole chicken (about 4 lbs)",
        "1 lemon, sliced",
        "4 cloves garlic, minced",
        "2 tbsp olive oil",
        "1 tsp dried thyme",
        "1 tsp dried rosemary",
        "Salt and pepper to taste",
      ],
      imageUrl: "assets/images/roastedchicken.jpeg",
    ),
    Recipe(
      name: "Quinoa Salad with Roasted Vegetables",
      directions:
          "Cook quinoa according to package instructions. Let it cool. Preheat oven to 400°F (200°C). Toss cherry tomatoes, zucchini, and red bell pepper with olive oil, balsamic vinegar, oregano, salt, and pepper. Spread on a baking sheet. Roast vegetables in the preheated oven for 20-25 minutes or until tender. In a large bowl, combine cooked quinoa and roasted vegetables. Garnish with crumbled feta cheese and fresh basil leaves.",
      ingredients: [
        "1 cup quinoa, rinsed",
        "2 cups cherry tomatoes, halved",
        "1 zucchini, sliced",
        "1 red bell pepper, diced",
        "1/4 cup olive oil",
        "2 tbsp balsamic vinegar",
        "1 tsp dried oregano",
        "Salt and pepper to taste",
        "Feta cheese for garnish",
        "Fresh basil leaves for garnish",
      ],
      imageUrl: "assets/images/roastedquinoa.jpeg",
    ),
    Recipe(
      name: "Avocado Toast",
      directions:
          "Toast the slices of whole-grain bread to your liking. While the bread is toasting, mash the ripe avocado in a bowl. Spread the mashed avocado evenly over the toasted bread. Sprinkle with salt, pepper, and red pepper flakes if desired. Drizzle with a bit of lemon juice for extra freshness. Serve and enjoy your quick and delicious avocado toast!",
      ingredients: [
        "2 slices whole-grain bread",
        "1 ripe avocado",
        "Salt and pepper to taste",
        "Red pepper flakes (optional)",
        "Lemon juice (optional)",
      ],
      imageUrl: "assets/images/avocadotoast.jpeg",
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
