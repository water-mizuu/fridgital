import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class Recipes extends StatelessWidget {
  const Recipes({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasicScreenWidget(
      child: MouseSingleChildScrollView(
        child: Column(
          children: [RecipeTitle(), SizedBox(height: 16.0), RecipeTile()],
        ),
      ),
    );
  }
}

class RecipeTitle extends StatelessWidget {
  const RecipeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 32.0) + const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Suggested\nRecipes".toUpperCase(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8.0),
          Text("Meals you can make based on your inventory.", style: theme.textTheme.displayLarge),
        ],
      ),
    );
  }
}

class RecipeTile extends StatelessWidget {
  const RecipeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: SizedBox(
          height: 200,
          child: ColoredBox(
            color: FigmaColors.whiteAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text("hi"),
                ),
                ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(127),
                    ],
                  ).createShader(Offset.zero & rect.size),
                  blendMode: BlendMode.dstIn,
                  child: ShaderMask(
                    shaderCallback: (rect) =>
                        const LinearGradient(colors: [FigmaColors.whiteAccent, FigmaColors.whiteAccent])
                            .createShader(Offset.zero & rect.size),
                    // blendMode: BlendMode.saturation,
                    // Uncomment the line above to remove the color of the image
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
