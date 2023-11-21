import "package:flutter/material.dart";

class CheckBox extends StatelessWidget {
  CheckBox({required this.itemNameToBuy, required this.itemObtainStatus, required this.onChanged, super.key});

  final String itemNameToBuy;
  final bool itemObtainStatus;
  // ignore: avoid_positional_boolean_parameters
  void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Checkbox(
            value: itemObtainStatus,
            onChanged: onChanged,
          ),
          Text(itemNameToBuy),
        ],
      ),
    );
  }
}
