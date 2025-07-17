/// Returns the value if it is the same type as [T], otherwise `null`.
///
/// [T] must be non-nullable since the return type is nullable.
T? safeCast<T extends Object>(Object? value) {
  return switch (value) {
    final T v => v,
    _ => null,
  };
}
