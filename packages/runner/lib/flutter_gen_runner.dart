import 'dart:convert';
import 'dart:io' show File;
import 'dart:isolate';

import 'package:build/build.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:glob/glob.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

Builder build(BuilderOptions options) => FlutterGenBuilder(options);
PostProcessBuilder postProcessBuild(BuilderOptions options) =>
    FlutterGenPostProcessBuilder();

/// Main builder for FlutterGen when used through `build_runner`.
///
/// The implementation is intentionally split into two phases:
///
/// 1. A normal [Builder] resolves the current target package, reads config from
///    the package-local assets visible to the current [BuildStep], and renders
///    the final generated file contents entirely in memory.
/// 2. The normal builder writes a single declared intermediate manifest.
/// 3. A [PostProcessBuilder] consumes that manifest and writes the actual
///    source outputs into the package.
///
/// This indirection is required because `flutter_gen.output` is configuration
/// driven. A normal builder must declare its outputs up front in
/// [buildExtensions], but FlutterGen's real `.gen.dart` paths are only known
/// after reading the package's `pubspec.yaml` / builder options. The manifest
/// gives us one fixed declared output while still allowing the materialization
/// step to write package-relative source files.
class FlutterGenBuilder extends Builder {
  FlutterGenBuilder(this._options);

  static const _manifestExtension = '.flutter_gen.manifest.json';
  static const _assetsName = 'assets.gen.dart';
  static const _colorsName = 'colors.gen.dart';
  static const _fontsName = 'fonts.gen.dart';

  final BuilderOptions _options;

  /// We resolve package roots from the runtime package configuration of the
  /// build script isolate.
  ///
  /// `buildStep.packageConfig` is package-aware, but the URIs exposed there are
  /// asset-style URIs. The legacy generator code still needs a real file-system
  /// root so it can reuse the existing `dart:io` based generation pipeline.
  /// Loading the isolate package config once gives us stable `file:` package
  /// roots for all packages in the build graph, including workspace members.
  static final Future<PackageConfig> _runtimePackageConfig =
      loadPackageConfigUri(Isolate.packageConfigSync!);

  @override
  Future<void> build(BuildStep buildStep) async {
    // Resolve the package being built from the current BuildStep instead of the
    // process working directory. This is the key workspace-safe behavior.
    final packageRoot = await _packageRoot(buildStep);
    final pubspecId = AssetId(buildStep.inputId.package, 'pubspec.yaml');

    // A missing pubspec means there is nothing meaningful to generate. We still
    // emit an empty manifest so the post-process step has a deterministic input
    // and can clean any previously owned outputs.
    if (!await buildStep.canRead(pubspecId)) {
      await _writeManifest(
        buildStep,
        FlutterGenManifest(
          packageName: buildStep.inputId.package,
          packageRoot: packageRoot,
          outputs: const [],
        ),
      );
      return;
    }

    // Read configuration through build_runner's asset APIs so that the read is
    // scoped to the active package in both single-package and workspace builds.
    final pubspecContent = await buildStep.readAsString(pubspecId);
    final pubspecLockId = AssetId(buildStep.inputId.package, 'pubspec.lock');
    final analysisOptionsId = AssetId(
      buildStep.inputId.package,
      'analysis_options.yaml',
    );
    final pubspecLockContent =
        await _readOptionalAsset(buildStep, pubspecLockId);
    final analysisOptionsContent = await _readOptionalAsset(
      buildStep,
      analysisOptionsId,
    );

    // `Config` still carries a `File pubspecFile` because the lower-level core
    // generator APIs remain file-system based. We construct a package-local file
    // path here after resolving the correct package root above.
    final pubspecFile = File(join(packageRoot, 'pubspec.yaml'));
    final config = loadPubspecConfigFromInputOrNull(
      ConfigLoadInput(
        pubspecFile: pubspecFile,
        pubspecContent: pubspecContent,
        // BuilderOptions are now the supported way to pass build.yaml options in
        // the build_runner path. This keeps config target-local and workspace
        // aware without relying on process cwd.
        buildOptions: _options.config,
        pubspecLockContent: pubspecLockContent,
        analysisOptionsContent: analysisOptionsContent,
      ),
    );

    // Keep the manifest contract deterministic even for invalid or unsupported
    // configurations. An empty manifest means "FlutterGen owns no outputs for
    // this package right now".
    if (config == null) {
      await _writeManifest(
        buildStep,
        FlutterGenManifest(
          packageName: buildStep.inputId.package,
          packageRoot: packageRoot,
          outputs: const [],
        ),
      );
      return;
    }

    // The legacy `FlutterGenerator` still reads asset metadata through
    // `dart:io`, but we must also teach build_runner which source assets this
    // action depends on so incremental rebuilds behave correctly. Digesting the
    // matched assets records those dependencies in the asset graph.
    await _trackInputs(config, buildStep);

    final outputs = <FlutterGenManifestOutput>[];

    // Reuse the existing core generator and capture its final file contents in
    // memory rather than writing them directly to disk. The post-process phase
    // will materialize them later.
    final generator = FlutterGenerator(
      pubspecFile,
      assetsName: _assetsName,
      colorsName: _colorsName,
      fontsName: _fontsName,
    );
    await generator.build(
      config: config,
      writer: (contents, path) {
        outputs.add(
          FlutterGenManifestOutput(
            path: relative(path, from: packageRoot),
            contents: contents,
          ),
        );
      },
    );

    // Persist the full generation result as a single manifest so the next phase
    // can write arbitrary source outputs without needing to recompute config or
    // re-read inputs.
    await _writeManifest(
      buildStep,
      FlutterGenManifest(
        packageName: buildStep.inputId.package,
        packageRoot: packageRoot,
        outputs: outputs,
      ),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        // The entire builder graph is anchored on one fixed declared output.
        // This is what lets us support configuration-dependent final paths.
        r'$package$': [_manifestExtension],
      };

  Future<void> _trackInputs(
    Config config,
    BuildStep buildStep,
  ) async {
    final pubspec = config.pubspec;

    // Asset generation depends on every matched flutter asset path. We mirror
    // the same glob expansion behavior here so build_runner can invalidate the
    // manifest whenever one of those inputs changes.
    if (pubspec.flutterGen.assets.enabled) {
      for (final asset in pubspec.flutter.assets) {
        String assetInput;
        if (asset is YamlMap) {
          assetInput = asset['path'];
        } else {
          assetInput = asset as String;
        }
        if (assetInput.isEmpty) {
          continue;
        }
        if (assetInput.endsWith('/')) {
          assetInput += '*';
        }
        await for (final assetId in buildStep.findAssets(Glob(assetInput))) {
          await buildStep.digest(assetId);
        }
      }
    }

    // Color generation also depends on the contents of its configured input
    // files. Digesting them is sufficient to establish the dependency edge.
    if (pubspec.flutterGen.colors.enabled) {
      for (final colorInput in pubspec.flutterGen.colors.inputs) {
        if (colorInput.isEmpty) {
          continue;
        }
        await for (final assetId in buildStep.findAssets(Glob(colorInput))) {
          await buildStep.digest(assetId);
        }
      }
    }
  }

  Future<String> _packageRoot(BuildStep buildStep) async {
    final packageConfig = await _runtimePackageConfig;
    final package = packageConfig[buildStep.inputId.package];
    if (package == null) {
      throw StateError(
        'Unable to resolve package root for ${buildStep.inputId.package}.',
      );
    }
    return normalize(package.root.toFilePath());
  }

  /// Reads an optional package-local asset if it exists.
  ///
  /// We keep this helper small because `pubspec.lock` and
  /// `analysis_options.yaml` are auxiliary configuration sources: their absence
  /// should not fail the entire generation step.
  Future<String?> _readOptionalAsset(
    BuildStep buildStep,
    AssetId assetId,
  ) async {
    if (!await buildStep.canRead(assetId)) {
      return null;
    }
    return buildStep.readAsString(assetId);
  }

  /// Writes the single declared intermediate artifact for this package.
  ///
  /// The manifest is intentionally JSON so the post-process phase can stay
  /// simple and self-contained: it reads one input, writes many outputs, and
  /// does not need access to any additional resources.
  Future<void> _writeManifest(
    BuildStep buildStep,
    FlutterGenManifest manifest,
  ) {
    return buildStep.writeAsString(
      AssetId(buildStep.inputId.package, _manifestExtension),
      jsonEncode(manifest.toJson()),
    );
  }
}

/// Materializes final source files from the manifest written by
/// [FlutterGenBuilder].
///
/// A post-process builder is the only supported way in the current build_runner
/// model to write source outputs whose paths are not statically known to the
/// original builder.
class FlutterGenPostProcessBuilder extends PostProcessBuilder {
  static const _manifestExtension = '.flutter_gen.manifest.json';
  static const _ownerFileName = 'flutter_gen_owner.json';

  @override
  Iterable<String> get inputExtensions => const [_manifestExtension];

  @override
  Future<void> build(PostProcessBuildStep buildStep) async {
    // The manifest contains the entire desired output state for one package.
    final manifest = FlutterGenManifest.fromJson(
      jsonDecode(await buildStep.readInputAsString()) as Map<String, Object?>,
    );

    // We persist ownership information outside the source tree so stale output
    // cleanup can compare "previously owned files" with "currently desired
    // files" across builds.
    final ownerFile = File(
      join(
        manifest.packageRoot,
        '.dart_tool',
        'flutter_build',
        'flutter_gen',
        _ownerFileName,
      ),
    );

    final previousOutputs = await _readOwnedPaths(ownerFile);
    final nextOutputs = manifest.outputs.map((output) => output.path).toSet();

    // Explicit stale cleanup is required because these source outputs are not
    // regular declared outputs of the original builder. build_runner manages the
    // manifest lifecycle, but FlutterGen owns the lifecycle of the final
    // materialized files.
    for (final output in previousOutputs.difference(nextOutputs)) {
      final absolutePath = normalize(join(manifest.packageRoot, output));
      if (!_isWithinPackage(manifest.packageRoot, absolutePath)) {
        continue;
      }
      final file = File(absolutePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    // Materialize the exact output set described by the manifest.
    //
    // These files are intentionally managed outside build_runner's declared
    // output model because their paths are configuration-dependent. Writing them
    // directly avoids `InvalidOutputException` when the same files already
    // exist, for example after a previous `fluttergen` command run or a stale
    // checked-out generated file.
    for (final output in manifest.outputs) {
      final file = File(join(manifest.packageRoot, output.path));
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      file.writeAsStringSync(output.contents);
    }

    if (!ownerFile.parent.existsSync()) {
      ownerFile.parent.createSync(recursive: true);
    }

    // Persist the new ownership snapshot after successful writes.
    ownerFile.writeAsStringSync(
      jsonEncode({
        'paths': nextOutputs.toList()..sort(),
      }),
    );
  }

  /// Reads the set of source files previously materialized for this package.
  Future<Set<String>> _readOwnedPaths(File ownerFile) async {
    if (!ownerFile.existsSync()) {
      return <String>{};
    }
    final raw =
        jsonDecode(await ownerFile.readAsString()) as Map<String, Object?>;
    final paths = raw['paths'];
    if (paths is! List) {
      return <String>{};
    }
    return paths.whereType<String>().toSet();
  }

  /// Guards cleanup against deleting files outside the active package.
  bool _isWithinPackage(String packageRoot, String candidatePath) {
    final normalizedRoot = normalize(packageRoot);
    final normalizedCandidate = normalize(candidatePath);
    return normalizedCandidate == normalizedRoot ||
        isWithin(normalizedRoot, normalizedCandidate);
  }
}

/// Self-contained description of the desired FlutterGen outputs for one package.
///
/// The manifest is designed to be replayable by the post-process builder with no
/// additional context: package root, package name, and final rendered file
/// contents are all embedded here.
class FlutterGenManifest {
  const FlutterGenManifest({
    required this.packageName,
    required this.packageRoot,
    required this.outputs,
  });

  factory FlutterGenManifest.fromJson(Map<String, Object?> json) {
    return FlutterGenManifest(
      packageName: json['package_name'] as String,
      packageRoot: json['package_root'] as String,
      outputs: (json['outputs'] as List<Object?>? ?? const [])
          .whereType<Map<String, Object?>>()
          .map(FlutterGenManifestOutput.fromJson)
          .toList(),
    );
  }

  final String packageName;
  final String packageRoot;
  final List<FlutterGenManifestOutput> outputs;

  Map<String, Object?> toJson() => {
        'schema_version': 1,
        'package_name': packageName,
        'package_root': packageRoot,
        'outputs': [for (final output in outputs) output.toJson()],
      };
}

/// One final generated source file captured inside a [FlutterGenManifest].
class FlutterGenManifestOutput {
  const FlutterGenManifestOutput({
    required this.path,
    required this.contents,
  });

  factory FlutterGenManifestOutput.fromJson(Map<String, Object?> json) {
    return FlutterGenManifestOutput(
      path: json['path'] as String,
      contents: json['contents'] as String,
    );
  }

  final String path;
  final String contents;

  Map<String, Object?> toJson() => {
        'path': path,
        'contents': contents,
      };
}
