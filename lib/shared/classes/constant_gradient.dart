import "package:flutter/material.dart";

class ConstantGradient extends LinearGradient {
  ConstantGradient({required Color color}) : super(colors: [color, color]);
}
