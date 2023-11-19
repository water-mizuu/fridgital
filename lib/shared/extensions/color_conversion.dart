// ignore_for_file: parameter_assignments, always_put_control_body_on_new_line

import "dart:math";

import "package:flutter/material.dart";

typedef Rgb = ({int r, int g, int b});
typedef Hsl = ({int h, double s, double l});

extension ColorConversionExtension on Color {
  Rgb get rgb => (r: red, g: green, b: blue);
  Hsl get hsl => rgb.hsl;

  Color desaturate(double rate) {
    var hsl = this.hsl;

    return hsl.copyWith(s: hsl.s * (1 - rate)).color;
  }

  Color dim(double rate) {
    var hsl = this.hsl;

    return hsl.copyWith(l: hsl.l * (1 - rate)).color;
  }
}

extension RgbMethods on Rgb {
  Hsl get hsl {
    var r = this.r / 255;
    var g = this.g / 255;
    var b = this.b / 255;

    var colorMin = [r, g, b].reduce(min);
    var colorMax = [r, g, b].reduce(max);
    var delta = colorMax - colorMin;
    var h = 0.0;
    var s = 0.0;
    var l = 0.0;

    /// Compute the hue.
    if (delta == 0) {
      h = 0;
    } else if (colorMax == r) {
      h = 60 * (((g - b) / delta) % 6);
    } else if (colorMax == g) {
      h = 60 * (((b - r) / delta) + 2);
    } else if (colorMax == b) {
      h = 60 * (((r - g) / delta) + 4);
    }
    h %= 360;

    l = (colorMax + colorMin) / 2;
    s = delta == 0 ? 0 : delta / (1 - (2 * l - 1).abs());

    return (h: h.round(), s: s, l: l);
  }

  Color get color => Color.fromRGBO(r, g, b, 1.0);

  Rgb copyWith({int? r, int? g, int? b}) => (r: r ?? this.r, g: g ?? this.g, b: b ?? this.b);
}

extension HslMethods on Hsl {
  Rgb get rgb {
    var h = this.h / 360;
    var s = this.s;
    var l = this.l;

    assert(0 <= h && h <= 1, "Hue must be between 0 and 1");
    assert(0 <= s && s <= 1, "Saturation must be between 0 and 1");
    assert(0 <= l && l <= 1, "Lightness must be between 0 and 1");

    double r;
    double g;
    double b;

    if (s == 0) {
      r = g = b = l;
    } else {
      var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      var p = 2 * l - q;
      r = _hueToRgb(p, q, h + 1 / 3);
      g = _hueToRgb(p, q, h);
      b = _hueToRgb(p, q, h - 1 / 3);
    }

    return (
      r: (r * 255).round(),
      g: (g * 255).round(),
      b: (b * 255).round(),
    );
  }

  double _hueToRgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  Color get color => rgb.color;

  Hsl copyWith({int? h, double? s, double? l}) => (h: h ?? this.h, s: s ?? this.s, l: l ?? this.l);
}
