class FlavoredAsset {
  const FlavoredAsset({
    required this.path,
    this.flavors = const {},
    this.transformers = const {},
  });

  final String path;
  final Set<String> flavors;
  final Set<String> transformers;

  FlavoredAsset copyWith({
    String? path,
    Set<String>? flavors,
    Set<String>? transformers,
  }) {
    return FlavoredAsset(
      path: path ?? this.path,
      flavors: flavors ?? this.flavors,
      transformers: transformers ?? this.transformers,
    );
  }

  @override
  String toString() =>
      'FlavoredAsset(path: $path, flavors: $flavors, transformers: $transformers)';
}
