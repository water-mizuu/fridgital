import "package:flutter/material.dart";

class ChangePageNotification extends Notification {
  const ChangePageNotification(this.index);

  final int index;
}
