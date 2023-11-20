import "dart:math" as math;

int levenshtein(String left, String right) {
  switch ((left.length, right.length)) {
    case (0, var rightLength):
      return rightLength;
    case (var leftLength, 0):
      return leftLength;
    case (var leftLength, var rightLength):
      var previousRow = List<int>.generate(rightLength + 1, (i) => i);
      for (var i = 0; i < leftLength; i++) {
        var currentRow = List<int>.filled(rightLength + 1, 0) //
          ..[0] = i + 1;

        for (var j = 0; j < rightLength; j++) {
          var cost = left[i] == right[j] ? 0 : 1;

          currentRow[j + 1] = [
            currentRow[j] + 1,
            previousRow[j + 1] + 1,
            previousRow[j] + cost,
          ].reduce(math.min);
        }
        previousRow = currentRow;
      }

      return previousRow[rightLength];
  }
}
