import "package:flutter/widgets.dart";
import "package:fridgital/shared/classes/selected_color.dart";

const int intMax = 1 << 63 - 1;

abstract final class FigmaColors {
  static const Color textDark = Color(0xFF2D2020);
  static const Color whiteAccent = Color(0xFFFFFDF6);
  static const Color pinkAccent = Color(0xFFB18887);
  static const Color lightGreyAccent = Color(0xFFC3B2B2);
}

abstract final class TagColors {
  static const Color selector = Color(0xffd37979);
  static const Color essential = Color(0xff5aa0a0);

  static const UserSelectableColor addButton = UserSelectableColor(0xffDAB39E);

  static const selectable = [
    UserSelectableColor(0xffA95454),
    UserSelectableColor(0xffC98060),
    UserSelectableColor(0xffDBAF9C),
    UserSelectableColor(0xffDDA767),
    UserSelectableColor(0xffD3BE96),
    UserSelectableColor(0xffADBD93),
    UserSelectableColor(0xff72A18D),
    UserSelectableColor(0xff5AA0A0),
    UserSelectableColor(0xff92A8C8),
    UserSelectableColor(0xff5476A9),
    UserSelectableColor(0xff615CA4),
    UserSelectableColor(0xff9879B1),
    UserSelectableColor(0xff7B558D),
    UserSelectableColor(0xffA57D71),
    UserSelectableColor(0xff8D5F4C),
    UserSelectableColor(0xff8C7973),
    UserSelectableColor(0xff665252),
  ];
}
