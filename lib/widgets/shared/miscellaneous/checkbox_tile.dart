import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/round_check_box.dart";

class CheckBox extends StatelessWidget {
  const CheckBox({
    required this.itemNameToBuy,
    required this.itemObtainStatus,
    required this.onChanged,
    required this.color,
    super.key,
  });

  final String itemNameToBuy;
  final bool itemObtainStatus;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: RoundCheckBox(
              color: color,
              value: itemObtainStatus,
              onChanged: onChanged,
            ),
          ),
        ),
        Text(
          itemNameToBuy,
          style: TextStyle(
            fontSize: 20.0,
            color: itemObtainStatus ? FigmaColors.lightGreyAccent : FigmaColors.textDark,
            fontStyle: itemObtainStatus ? FontStyle.italic : FontStyle.normal,
            decoration: itemObtainStatus ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: FigmaColors.lightGreyAccent,
          ),
        ),
      ],
    );
  }
}
