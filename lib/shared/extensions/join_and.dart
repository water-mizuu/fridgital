extension JoinAnd<E> on List<E> {
  String joinAnd() => switch (this) {
        [] => "",
        [var single] => single.toString(),
        [var first, var last] => "$first and $last",
        [...var head, var tail] => "${head.join(", ")}, and $tail",
      };
}
