import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers/recipe_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class RecipeInfo extends StatefulHookWidget {
  const RecipeInfo({required this.recipe, super.key});

  final Recipe recipe;

  @override
  State<RecipeInfo> createState() => _RecipeInfoState();
}

class _RecipeInfoState extends State<RecipeInfo> {
  static const double _threshold = 648.0;

  late final ScrollController scrollController;

  late double scrollPercentage = scrollController.hasClients //
      ? scrollController.offset / _threshold
      : 0.0;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController()
      ..addListener(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            scrollPercentage = scrollController.offset / _threshold;
          });
        });
      });
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      body: FractionallySizedBox(
        widthFactor: 1.0,
        child: TagDataProvider(
          builder: (context, tagData) => BasicScreenWidget(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0) + const EdgeInsets.only(top: 24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Center(
                        child: ClickableWidget(
                          onTap: () {
                            RouteState.of(context).workingRecipe = null;
                          },
                          child: const Icon(Icons.arrow_back_ios_rounded),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(widget.recipe.name.toUpperCase(), style: theme.textTheme.titleLarge),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: MouseSingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      controller: scrollController,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          var width = constraints.maxWidth;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (widget.recipe.imageUrl case var imageUrl?) ...[
                                ImageDisplay(width: width, imageUrl: imageUrl),
                                const ColoredBox(
                                  color: FigmaColors.whiteAccent,
                                  child: SizedBox(height: 16.0),
                                ),
                              ],
                              Container(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                color: FigmaColors.whiteAccent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Ingredients: ",
                                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 32.0),
                                  ),
                                ),
                              ),
                              for (var ingredient in widget.recipe.ingredients)
                                Container(
                                  color: FigmaColors.whiteAccent,
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: ListTile(
                                    leading: Text(
                                      ingredient,
                                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16.0),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    minVerticalPadding: 0.0,
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                                color: FigmaColors.whiteAccent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Directions: ",
                                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 32.0),
                                  ),
                                ),
                              ),
                              Container(
                                color: FigmaColors.whiteAccent,
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  widget.recipe.directions,
                                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16.0),
                                ),
                              ),
                              Container(
                                height: 16.0,
                                decoration: const BoxDecoration(
                                  color: FigmaColors.whiteAccent,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12.0),
                                    bottomRight: Radius.circular(12.0),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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

class ImageDisplay extends StatelessWidget {
  const ImageDisplay({
    required this.width,
    required this.imageUrl,
    super.key,
  });

  final double width;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 200.0,
      child: Stack(
        children: [
          Positioned(
            bottom: 0.0,
            child: Container(
              height: 100.0,
              width: width,
              decoration: const BoxDecoration(
                color: FigmaColors.whiteAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(9.0)),
              child: Image.asset(
                imageUrl,
                height: 200.0,
                width: 200.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
