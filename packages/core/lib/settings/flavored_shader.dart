class FlavoredShader {
  const FlavoredShader({
    required this.path,
    this.flavors = const {},
  });

  final String path;
  final Set<String> flavors;

  FlavoredShader copyWith({String? path, Set<String>? flavors}) {
    return FlavoredShader(
      path: path ?? this.path,
      flavors: flavors ?? this.flavors,
    );
  }

  @override
  String toString() => 'FlavoredShader(path: $path, flavors: $flavors)';
}
