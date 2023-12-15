import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers/recipe_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/join_and.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";

class RecipeTile extends HookWidget {
  const RecipeTile({required this.recipe, super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    var Recipe(:name, :ingredients, :imageUrl) = useListenable(recipe);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0) + const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: ClickableWidget(
          onTap: () {
            RouteState.of(context).workingRecipe = recipe;
          },
          child: Container(
            height: 175,
            color: FigmaColors.whiteAccent,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0) + const EdgeInsets.symmetric(vertical: 12.0),
                      child: SizedBox(
                        width: (constraints.maxWidth * 0.50).clamp(150, double.infinity),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                              ),
                            ),
                            Text(
                              "Contains ${ingredients.map((v) => "'$v'").toList().joinAnd()}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: const TextStyle(
                                color: FigmaColors.darkGreyAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            const Text(
                              "view recipe...",
                              style: TextStyle(
                                color: FigmaColors.darkGreyAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (imageUrl case String imageUrl)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Builder(
                        builder: (context) {
                          var widget = AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.asset(imageUrl, width: 200, fit: BoxFit.cover),
                          ) as Widget;

                          // widget = ShaderMask(
                          //   shaderCallback: (rect) => const LinearGradient(
                          //     colors: [
                          //       FigmaColors.whiteAccent,
                          //       FigmaColors.whiteAccent,
                          //     ],
                          //   ).createShader(Offset.zero & rect.size),
                          //   blendMode: BlendMode.color,
                          //   child: widget,
                          // );

                          // Uncomment the line above to remove the color of the image

                          widget = ShaderMask(
                            shaderCallback: (rect) => LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(127),
                              ],
                            ).createShader(Offset.zero & rect.size),
                            blendMode: BlendMode.dstIn,
                            child: widget,
                          );

                          return widget;
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
