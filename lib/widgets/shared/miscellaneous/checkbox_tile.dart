import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/round_check_box.dart";

class CheckBox extends StatelessWidget {
  CheckBox({required this.itemNameToBuy, required this.itemObtainStatus, required this.onChanged, super.key});

  final String itemNameToBuy;
  final bool itemObtainStatus;
  // ignore: avoid_positional_boolean_parameters
  void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: RoundCheckBox(
                color: TagColors.selectable[2],
                value: itemObtainStatus,
                onChanged: onChanged,
              ),
            ),
          ),
          Text(
            itemNameToBuy,
            style: TextStyle(fontSize: 20.0),
          ),
        ],
      ),
    );
  }
}
