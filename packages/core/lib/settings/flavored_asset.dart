class FlavoredAsset {
  const FlavoredAsset({
    required this.path,
    required this.flavors,
  });

  final String path;
  final Set<String> flavors;

  FlavoredAsset copyWith({String? path, Set<String>? flavors}) {
    return FlavoredAsset(
      path: path ?? this.path,
      flavors: flavors ?? this.flavors,
    );
  }
}
