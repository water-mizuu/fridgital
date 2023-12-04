import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/join_and.dart";

class RecipeTile extends StatelessWidget {
  const RecipeTile({
    required this.title,
    required this.ingredients,
    required this.imageUrl,
    super.key,
  });

  final String title;
  final List<String> ingredients;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                            title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                            ),
                          ),
                          Text(
                            "Contains ${ingredients.joinAnd()}",
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
                      //   blendMode: BlendMode.dstIn,
                      //   child: widget,
                      // );

                      // Uncomment the line above to remove the color of the image

                      // ignore: join_return_with_assignment
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
    );
  }
}
