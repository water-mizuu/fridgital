extension NormalizeNumber<N extends num> on N {
  double normalize<N1 extends num, N2 extends num>({required N1 between, required N2 and}) {
    var shiftedValue = this - between;
    var shiftedBound = and - between;

    if (shiftedValue / shiftedBound case var number when !number.isNaN) {
      return number;
    }

    return 0.0;
  }
}
