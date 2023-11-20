import 'package:flutter/material.dart';

class CheckBox extends StatelessWidget {
  final String itemNameToBuy;
  final bool itemObtainStatus;
  Function(bool?)? onChanged;

  CheckBox({super.key, required this.itemNameToBuy, required this.itemObtainStatus, required this.onChanged});

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
    ));
  }
}
