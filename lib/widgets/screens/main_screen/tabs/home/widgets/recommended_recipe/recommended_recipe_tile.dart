import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/recipe_data.dart";
import "package:fridgital/shared/classes/constant_gradient.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/join_and.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home/notifications.dart";

class RecommendedRecipeTile extends StatelessWidget {
  const RecommendedRecipeTile({
    required this.index,
    required this.recipe,
    required this.activePage,
    super.key,
  });

  final int index;
  final Recipe recipe;
  final ValueNotifier<int?> activePage;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: activePage,
      builder: (context, child) {
        if (activePage.value case int value when value != index) {
          return MouseRegion(cursor: SystemMouseCursors.click, child: child);
        }
        return MouseRegion(cursor: SystemMouseCursors.click, child: child);
      },
      child: GestureDetector(
        onTap: () async {
          if (!context.mounted) {
            return;
          }

          if (activePage.value case int page when page != index) {
            ChangePageNotification(index).dispatch(context);
          } else {
            RouteState.of(context).workingRecipe = recipe;
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColoredBox(
            color: FigmaColors.recipeWidgetBackground,
            child: Stack(
              children: [
                if (recipe.imageUrl case var imageUrl?)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ShaderMask(
                      shaderCallback: (rect) => //
                          const LinearGradient(colors: [Colors.transparent, Colors.black])
                              .createShader(Offset.zero & rect.size),
                      blendMode: BlendMode.dstIn,
                      child: ShaderMask(
                        shaderCallback: (rect) => //
                            ConstantGradient(color: FigmaColors.recipeWidgetBackground) //
                                .createShader(Offset.zero & rect.size),
                        blendMode: BlendMode.color,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Image.asset(
                            imageUrl,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0) + const EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.name.toUpperCase(),
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24.0,
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                Text(
                                  "Contains ${recipe.ingredients.toList().joinAnd()}",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                                const Text(
                                  "Click to view recipe.",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 64.0),
                        ],
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
