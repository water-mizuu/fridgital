extension AsExtension<T extends Object> on T {
  R as<R extends Object>() => this as R;
}
