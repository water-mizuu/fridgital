extension TimeExtension on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get s => Duration(seconds: this);
  Duration get min => Duration(minutes: this);
  Duration get hrs => Duration(hours: this);
  Duration get days => Duration(days: this);
}
