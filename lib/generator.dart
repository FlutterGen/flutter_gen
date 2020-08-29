import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

abstract class Generator {
  Generator(AssetId assetId) : _assetId = assetId;

  final AssetId _assetId;

  AssetId get output => _assetId;

  void generate(YamlList assetsList);
}
