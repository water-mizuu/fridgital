import "dart:async";
import "dart:ui";

import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/overlays/create_tag_overlay.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/overlays/edit_tag_overlay.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/overlays/select_delete_overlay.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/overlays/select_edit_overlay.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/overlays/select_tag_overlay.dart";
import "package:provider/provider.dart";

class OverlayHolder extends StatefulWidget {
  const OverlayHolder({super.key});

  @override
  State<OverlayHolder> createState() => _OverlayHolderState();
}

class _OverlayHolderState extends State<OverlayHolder> with TickerProviderStateMixin {
  late final AnimationController animationController;
  late final ValueNotifier<OverlayMode> overlayMode;
  late final ValueNotifier<CustomTag?> workingTag;

  Future<void> transitionTo(OverlayMode mode) async {
    await animationController.reverse(from: 1.0);
    overlayMode.value = mode;
    await animationController.forward(from: 0.0);
  }

  Future<void> handleNotification(OverlayNotification notification) async {
    var tagData = context.read<TagData>();

    switch (notification) {
      case SwitchOverlayNotification(:var mode):
        await transitionTo(mode);

      case SelectedTagOverlayNotification(:var tag):
        await animationController.reverse(from: 1.0);
        tagData.addTag(tag);

        if (context.mounted) {
          const CloseOverlayNotification().dispatch(context);
        }

      case CloseOverlayNotification():
        await animationController.reverse(from: 1.0);

        if (context.mounted) {
          const CloseOverlayNotification().dispatch(context);
        }

      case CreateNewTagOverlayNotification(:var name, :var color):
        await tagData.addAddableTag(name: name, color: color);
        await transitionTo(OverlayMode.select);

      case ModifyWorkingTagNotification(:var name, :var color):
        var toReplace = workingTag.value!;
        var tag = CustomTag(toReplace.id, name, color);

        await tagData.replaceAddableTag(toReplace, tag);
        await transitionTo(OverlayMode.select);
        workingTag.value = null;

      case ChooseWorkingTagNotification(:var tag):
        workingTag.value = tag;

      case DeleteTagNotification(:var tag):
        await tagData.removeAddableTag(tag);
        await transitionTo(OverlayMode.select);
    }
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: 250.ms);
    overlayMode = ValueNotifier(OverlayMode.select);
    workingTag = ValueNotifier<CustomTag?>(null);

    animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    var tagData = context.read<TagData>();

    return NotificationListener<OverlayNotification>(
      onNotification: (notification) {
        unawaited(handleNotification(notification));

        return true;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          await animationController.reverse(from: 1.0);

          if (context.mounted) {
            const CloseOverlayNotification().dispatch(context);
          }
        },
        child: ChangeNotifierProvider.value(
          value: tagData,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color(0x7fCCAEBB),
            body: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: ListenableBuilder(
                listenable: overlayMode,
                builder: (context, child) => Center(
                  child: ValueListenableBuilder(
                    valueListenable: animationController,
                    builder: (context, animation, child) => Opacity(
                      opacity: animation,
                      child: Transform.scale(
                        scale: (0.8 + 0.4 * animation).clamp(0.0, 1.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.95),
                          child: child,
                        ),
                      ),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: workingTag,
                      builder: (context, tag, child) => switch (overlayMode.value) {
                        OverlayMode.select => const SelectTagOverlay(),
                        OverlayMode.add => const CreateTagOverlay(),

                        ///
                        OverlayMode.edit => EditTagOverlay(tag: tag!),
                        OverlayMode.selectEdit => const SelectEditOverlay(),
                        OverlayMode.selectDelete => const SelectDeleteOverlay(),
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
