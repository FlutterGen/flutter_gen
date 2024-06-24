class FlavoredAsset {
  const FlavoredAsset({
    required this.path,
    this.flavors = const {},
  });

  final String path;
  final Set<String> flavors;

  FlavoredAsset copyWith({String? path, Set<String>? flavors}) {
    return FlavoredAsset(
      path: path ?? this.path,
      flavors: flavors ?? this.flavors,
    );
  }

  @override
  String toString() => 'FlavoredAsset(path: $path, flavors: $flavors)';
}
