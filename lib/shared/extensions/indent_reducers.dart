import "package:flutter/material.dart";

extension CommonWidgetWrapperExtension on Widget {
  Widget withClipRRect({
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
    Key? key,
  }) =>
      ClipRRect(
        key: key,
        borderRadius: borderRadius,
        clipper: clipper,
        clipBehavior: clipBehavior,
        child: this,
      );

  Widget withPadding({required EdgeInsets padding, Key? key}) => Padding(
        key: key,
        padding: padding,
        child: this,
      );

  Widget withIgnorePointer({Key? key}) => IgnorePointer(
        key: key,
        child: this,
      );

  Widget withSizedBox({double? width, double? height, Key? key}) => SizedBox(
        key: key,
        width: width,
        height: height,
        child: this,
      );
}
