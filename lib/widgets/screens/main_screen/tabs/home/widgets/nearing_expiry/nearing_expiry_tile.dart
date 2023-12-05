import "package:flutter/material.dart";
import "package:fridgital/shared/classes/constant_gradient.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home/notifications.dart";

class NearingExpiryTile extends StatelessWidget {
  const NearingExpiryTile({
    required this.index,
    required this.activePage,
    super.key,
  });

  final int index;
  final ValueNotifier<int?> activePage;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: activePage,
      builder: (context, child) {
        if (activePage.value case int value when value != index) {
          return MouseRegion(cursor: SystemMouseCursors.click, child: child);
        }
        return child!;
      },
      child: GestureDetector(
        onTap: () async {
          if (activePage.value case int page when page != index && context.mounted) {
            ChangePageNotification(index).dispatch(context);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColoredBox(
            color: FigmaColors.expiryWidgetBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text("${index % 5}"),
                ),
                ShaderMask(
                  shaderCallback: (rect) => //
                      const LinearGradient(colors: [Colors.transparent, Colors.black])
                          .createShader(Offset.zero & rect.size),
                  blendMode: BlendMode.dstIn,
                  child: ShaderMask(
                    shaderCallback: (rect) => //
                        ConstantGradient(color: FigmaColors.expiryWidgetBackground) //
                            .createShader(Offset.zero & rect.size),
                    blendMode: BlendMode.color,
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
