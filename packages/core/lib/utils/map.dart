// Copy from https://pub.dev/packages/merge_map

/// Exposes the [mergeMap] function, which... merges Maps.
_copyValues<K, V>(
    Map<K, V> from, Map<K, V> to, bool recursive, bool acceptNull) {
  for (final key in from.keys) {
    if (from[key] is Map<K, V> && recursive) {
      if (to[key] is! Map<K, V>) {
        to[key] = <K, V>{} as V;
      }
      _copyValues(from[key] as Map, to[key] as Map, recursive, acceptNull);
    } else {
      if (from[key] != null || acceptNull) to[key] = from[key] as V;
    }
  }
}

/// Merges the values of the given maps together.
///
/// `recursive` is set to `true` by default. If set to `true`,
/// then nested maps will also be merged. Otherwise, nested maps
/// will overwrite others.
///
/// `acceptNull` is set to `false` by default. If set to `false`,
/// then if the value on a map is `null`, it will be ignored, and
/// that `null` will not be copied.
Map<K, V> mergeMap<K, V>(Iterable<Map<K, V>?> maps,
    {bool recursive = true, bool acceptNull = false}) {
  final result = <K, V>{};
  // ignore: avoid_function_literals_in_foreach_calls
  maps.forEach((map) {
    if (map != null) _copyValues(map, result, recursive, acceptNull);
  });
  return result;
}
