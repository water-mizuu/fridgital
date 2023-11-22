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

  static const TagColor addButton = TagColor(0xffDAB39E);

  static const selectable = [
    TagColor(0xffA95454),
    TagColor(0xffC98060),
    TagColor(0xffDBAF9C),
    TagColor(0xffDDA767),
    TagColor(0xffD3BE96),
    TagColor(0xffADBD93),
    TagColor(0xff72A18D),
    TagColor(0xff5AA0A0),
    TagColor(0xff92A8C8),
    TagColor(0xff5476A9),
    TagColor(0xff615CA4),
    TagColor(0xff9879B1),
    TagColor(0xff7B558D),
    TagColor(0xffA57D71),
    TagColor(0xff8D5F4C),
    TagColor(0xff8C7973),
    TagColor(0xff665252),
  ];
}
