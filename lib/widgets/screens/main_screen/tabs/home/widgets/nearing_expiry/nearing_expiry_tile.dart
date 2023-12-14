import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/shared/classes/constant_gradient.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home/notifications.dart";

class NearingExpiryTile extends StatelessWidget {
  const NearingExpiryTile({
    required this.index,
    required this.product,
    required this.activePage,
    super.key,
  });

  static const List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  final int index;
  final Product product;
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
            child: Stack(
              children: [
                if (product.imageBytes case var bytes?)
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
                              ConstantGradient(color: FigmaColors.expiryWidgetBackground) //
                                  .createShader(Offset.zero & rect.size),
                          blendMode: BlendMode.color,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.memory(
                              bytes,
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
                                  product.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24.0,
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                Text(
                                  switch (product.expiryDate?.difference(DateTime.now()).inDays) {
                                    int days => "Expires in $days days",
                                    _ => switch (product.addedDate.difference(DateTime.now()).inDays) {
                                        int days => "Added $days days ago",
                                      },
                                  },
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                                Text(
                                  switch (product.addedDate) {
                                    var date => "Added on ${date.month}/${date.day}/${date.year}",
                                  },
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
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
