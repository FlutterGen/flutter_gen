import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart' hide IterableSorted;
import 'package:flutter_gen_core/generators/generator_helper.dart';
import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/settings/flavored_shader.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:flutter_gen_core/settings/shader_type.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/string.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class ShadersGenConfig {
  ShadersGenConfig._(
    this.rootPath,
    this._packageName,
    this.flutterGen,
    this.shaders,
    this.exclude,
  );

  factory ShadersGenConfig.fromConfig(File pubspecFile, Config config) {
    return ShadersGenConfig._(
      pubspecFile.parent.absolute.path,
      config.pubspec.packageName,
      config.pubspec.flutterGen,
      config.pubspec.flutter.shaders,
      config.pubspec.flutterGen.shaders.exclude.map(Glob.new).toList(),
    );
  }

  final String rootPath;
  final String _packageName;
  final FlutterGen flutterGen;
  final List<Object> shaders;
  final List<Glob> exclude;

  String get packageParameterLiteral =>
      flutterGen.shaders.outputs.packageParameterEnabled ? _packageName : '';
}

Future<String> generateShaders(
  ShadersGenConfig config,
  DartFormatter formatter,
) async {
  if (config.shaders.isEmpty) {
    throw const InvalidSettingsException(
      'The value of "flutter/shaders:" is incorrect.',
    );
  }

  // ignore: deprecated_member_use_from_same_package
  final deprecatedStyle = config.flutterGen.shaders.style != null;
  final deprecatedPackageParam =
      // ignore: deprecated_member_use_from_same_package
      config.flutterGen.shaders.packageParameterEnabled != null;
  if (deprecatedStyle || deprecatedPackageParam) {
    stderr.writeln('''
                                                                                        
                ░░░░                                                                    
                                                                                        
                                            ██                                          
                                          ██░░██                                        
  ░░          ░░                        ██░░░░░░██                            ░░░░      
                                      ██░░░░░░░░░░██                                    
                                      ██░░░░░░░░░░██                                    
                                    ██░░░░░░░░░░░░░░██                                  
                                  ██░░░░░░██████░░░░░░██                                
                                  ██░░░░░░██████░░░░░░██                                
                                ██░░░░░░░░██████░░░░░░░░██                              
                                ██░░░░░░░░██████░░░░░░░░██                              
                              ██░░░░░░░░░░██████░░░░░░░░░░██                            
                            ██░░░░░░░░░░░░██████░░░░░░░░░░░░██                          
                            ██░░░░░░░░░░░░██████░░░░░░░░░░░░██                          
                          ██░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░██                        
                          ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██                        
                        ██░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░██                      
                        ██░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░██                      
                      ██░░░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░░░██                    
        ░░            ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██                    
                        ██████████████████████████████████████████                      
                                                                                        
                                                                                        
                  ░░''');
  }
  if (deprecatedStyle && deprecatedPackageParam) {
    stderr.writeln('''
    ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
    │ ⚠️  Warning                                                                                     │
    │   The `style` and `package_parameter_enabled` property moved from shader to under shader.output. │
    │   It should be changed in the following pubspec.yaml.                                          │
    │   https://github.com/FlutterGen/flutter_gen/pull/294                                           │
    │                                                                                                │
    │ [pubspec.yaml]                                                                                 │
    │                                                                                                │
    │  flutter_gen:                                                                                  │
    │    shaders:                                                                                     │
    │      outputs:                                                                                  │
    │        style: snake-case                                                                       │
    │        package_parameter_enabled: true                                                         │
    └────────────────────────────────────────────────────────────────────────────────────────────────┘''');
  } else if (deprecatedStyle) {
    stderr.writeln('''
    ┌───────────────────────────────────────────────────────────────────────┐
    │ ⚠️  Warning                                                            │
    │   The `style` property moved from shader to under shader.output.        │
    │   It should be changed in the following ways                          │
    │   https://github.com/FlutterGen/flutter_gen/pull/294                  │
    │                                                                       │
    │ [pubspec.yaml]                                                        │
    │                                                                       │
    │  flutter_gen:                                                         │
    │    shaders:                                                            │
    │      outputs:                                                         │
    │        style: snake-case                                              │
    └───────────────────────────────────────────────────────────────────────┘''');
  } else if (deprecatedPackageParam) {
    stderr.writeln('''
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │ ⚠️  Warning                                                                             │
    │   The `package_parameter_enabled` property moved from shader to under shader.output.     │
    │   It should be changed in the following pubspec.yaml.                                  │
    │   https://github.com/FlutterGen/flutter_gen/pull/294                                   │
    │                                                                                        │
    │ [pubspec.yaml]                                                                         │
    │                                                                                        │
    │  flutter_gen:                                                                          │
    │    shaders:                                                                             │
    │      outputs:                                                                          │
    │        package_parameter_enabled: true                                                 │
    └────────────────────────────────────────────────────────────────────────────────────────┘''');
  }

  final classesBuffer = StringBuffer();
  if (config.flutterGen.shaders.outputs.isDotDelimiterStyle) {
    final definition = await _dotDelimiterStyleDefinition(config);
    classesBuffer.writeln(definition);
  } else if (config.flutterGen.shaders.outputs.isSnakeCaseStyle) {
    final definition = await _snakeCaseStyleDefinition(config);
    classesBuffer.writeln(definition);
  } else if (config.flutterGen.shaders.outputs.isCamelCaseStyle) {
    final definition = await _camelCaseStyleDefinition(config);
    classesBuffer.writeln(definition);
  } else {
    throw 'The value of "flutter_gen/shaders/style." is incorrect.';
  }

  final imports = <Import>{};

  final importsBuffer = StringBuffer();
  for (final e in imports.sorted((a, b) => a.import.compareTo(b.import))) {
    importsBuffer.writeln(import(e));
  }

  final buffer = StringBuffer();
  buffer.writeln(header);
  buffer.writeln(ignore);
  buffer.writeln(importsBuffer.toString());
  buffer.writeln(classesBuffer.toString());
  return formatter.format(buffer.toString());
}

String? generateShadersPackageNameForConfig(ShadersGenConfig config) {
  if (config.flutterGen.shaders.outputs.packageParameterEnabled) {
    return config._packageName;
  } else {
    return null;
  }
}

/// Returns a list of all relative path shaders that are to be considered.
List<FlavoredShader> _getShaderRelativePathList(
  /// The absolute root path of the shaders directory.
  String rootPath,

  /// List of shaders as provided the `flutter -> shaders`
  /// section in the pubspec.yaml.
  List<Object> shaders,

  /// List of globs as provided the `flutter_gen -> shaders -> exclude`
  /// section in the pubspec.yaml.
  List<Glob> excludes,
) {
  // Normalize.
  final normalizedShaders = <Object>{...shaders.whereType<String>()};
  final normalizingMap = <String, Set<String>>{};
  // Resolve flavored shaders.
  for (final map in shaders.whereType<YamlMap>()) {
    final path = (map['path'] as String).trim();
    final flavors =
        (map['flavors'] as YamlList?)?.toSet().cast<String>() ?? <String>{};
    if (normalizingMap.containsKey(path)) {
      // https://github.com/flutter/flutter/blob/5187cab7bdd434ca74abb45895d17e9fa553678a/packages/flutter_tools/lib/src/shader.dart#L1137-L1139
      throw StateError(
        'Multiple shaders entries include the file "$path", '
        'but they specify different lists of flavors.',
      );
    }
    normalizingMap[path] = flavors;
  }
  for (final entry in normalizingMap.entries) {
    normalizedShaders.add(
      YamlMap.wrap({'path': entry.key, 'flavors': entry.value}),
    );
  }

  final shaderRelativePathList = <FlavoredShader>[];
  for (final shader in normalizedShaders) {
    final FlavoredShader tempShader;
    if (shader is YamlMap) {
      tempShader =
          FlavoredShader(path: shader['path'], flavors: shader['flavors']);
    } else {
      tempShader = FlavoredShader(path: (shader as String).trim());
    }
    final shaderAbsolutePath = join(rootPath, tempShader.path);
    if (FileSystemEntity.isDirectorySync(shaderAbsolutePath)) {
      shaderRelativePathList.addAll(Directory(shaderAbsolutePath)
          .listSync()
          .whereType<File>()
          .map(
            (e) => tempShader.copyWith(path: relative(e.path, from: rootPath)),
          )
          .toList());
    } else if (FileSystemEntity.isFileSync(shaderAbsolutePath)) {
      shaderRelativePathList.add(
        tempShader.copyWith(path: relative(shaderAbsolutePath, from: rootPath)),
      );
    }
  }

  if (excludes.isEmpty) {
    return shaderRelativePathList;
  }
  return shaderRelativePathList
      .where(
          (shader) => !excludes.any((exclude) => exclude.matches(shader.path)))
      .toList();
}

ShaderType _constructShaderTree(
  List<FlavoredShader> shaderRelativePathList,
  String rootPath,
) {
  // Relative path is the key
  final shaderTypeMap = <String, ShaderType>{
    '.': ShaderType(rootPath: rootPath, path: '.', flavors: {}),
  };
  for (final shader in shaderRelativePathList) {
    String path = shader.path;
    while (path != '.') {
      shaderTypeMap.putIfAbsent(
        path,
        () =>
            ShaderType(rootPath: rootPath, path: path, flavors: shader.flavors),
      );
      path = dirname(path);
    }
  }
  // Construct the ShaderType tree
  for (final shaderType in shaderTypeMap.values) {
    if (shaderType.path == '.') {
      continue;
    }
    final parentPath = dirname(shaderType.path);
    shaderTypeMap[parentPath]?.addChild(shaderType);
  }
  return shaderTypeMap['.']!;
}

Future<_Statement?> _createShaderTypeStatement(
  ShadersGenConfig config,
  UniqueShaderType shaderType,
) async {
  final childShaderAbsolutePath = join(config.rootPath, shaderType.path);
  if (FileSystemEntity.isDirectorySync(childShaderAbsolutePath)) {
    final childClassName = '\$${shaderType.path.camelCase().capitalize()}Gen';
    return _Statement(
      type: childClassName,
      filePath: shaderType.posixStylePath,
      name: shaderType.name,
      value: '$childClassName()',
      isConstConstructor: true,
      isDirectory: true,
      needDartDoc: false,
    );
  } else if (!shaderType.isIgnoreFile) {
    var shaderKey = shaderType.posixStylePath;
    if (config.flutterGen.shaders.outputs.packageParameterEnabled) {
      shaderKey = 'packages/${config._packageName}/$shaderKey';
    }
    return _Statement(
      type: 'String',
      filePath: shaderType.posixStylePath,
      name: shaderType.name,
      value: '\'$shaderKey\'',
      isConstConstructor: false,
      isDirectory: false,
      needDartDoc: true,
    );
  }
  return null;
}

/// Generate style like Shaders.foo.bar
Future<String> _dotDelimiterStyleDefinition(
  ShadersGenConfig config,
) async {
  final rootPath = Directory(config.rootPath).absolute.uri.toFilePath();
  final buffer = StringBuffer();
  final className = config.flutterGen.shaders.outputs.className;
  final shaderRelativePathList = _getShaderRelativePathList(
    rootPath,
    config.shaders,
    config.exclude,
  );
  final shadersStaticStatements = <_Statement>[];

  final shaderTypeQueue = ListQueue<ShaderType>.from(
    _constructShaderTree(shaderRelativePathList, rootPath).children,
  );

  while (shaderTypeQueue.isNotEmpty) {
    final shaderType = shaderTypeQueue.removeFirst();
    String shaderPath = join(rootPath, shaderType.path);
    final isDirectory = FileSystemEntity.isDirectorySync(shaderPath);
    if (isDirectory) {
      shaderPath = Directory(shaderPath).absolute.uri.toFilePath();
    } else {
      shaderPath = File(shaderPath).absolute.uri.toFilePath();
    }

    final isRootShader = !isDirectory &&
        File(shaderPath).parent.absolute.uri.toFilePath() == rootPath;
    // Handles directories, and explicitly handles root path shaders.
    if (isDirectory || isRootShader) {
      final List<_Statement?> results = await Future.wait(
        shaderType.children
            .mapToUniqueShaderType(camelCase, justBasename: true)
            .map(
              (e) => _createShaderTypeStatement(config, e),
            ),
      );
      final statements = results.whereType<_Statement>().toList();

      if (shaderType.isDefaultShadersDirectory) {
        shadersStaticStatements.addAll(statements);
      } else if (!isDirectory && isRootShader) {
        // Creates explicit statement.
        final statement = await _createShaderTypeStatement(
          config,
          UniqueShaderType(shaderType: shaderType, style: camelCase),
        );
        shadersStaticStatements.add(statement!);
      } else {
        final className = '\$${shaderType.path.camelCase().capitalize()}Gen';
        buffer.writeln(
          _directoryClassGenDefinition(
            className,
            statements,
            config.flutterGen.shaders.outputs.directoryPathEnabled
                ? shaderType.posixStylePath
                : null,
          ),
        );
        // Add this directory reference to Shaders class
        // if we are not under the default shader folder
        if (dirname(shaderType.path) == '.') {
          shadersStaticStatements.add(_Statement(
            type: className,
            filePath: shaderType.posixStylePath,
            name: shaderType.baseName.camelCase(),
            value: '$className()',
            isConstConstructor: true,
            isDirectory: true,
            needDartDoc: true,
          ));
        }
      }

      shaderTypeQueue.addAll(shaderType.children);
    }
  }
  final String? packageName = generateShadersPackageNameForConfig(config);
  buffer.writeln(
    _dotDelimiterStyleShadersClassDefinition(
      className,
      shadersStaticStatements,
      packageName,
    ),
  );
  return buffer.toString();
}

/// Generate style like Shaders.foo_bar
Future<String> _snakeCaseStyleDefinition(
  ShadersGenConfig config,
) {
  return _flatStyleDefinition(
    config,
    snakeCase,
  );
}

/// Generate style like Shaders.fooBar
Future<String> _camelCaseStyleDefinition(
  ShadersGenConfig config,
) {
  return _flatStyleDefinition(
    config,
    camelCase,
  );
}

Future<String> _flatStyleDefinition(
  ShadersGenConfig config,
  String Function(String) style,
) async {
  final List<FlavoredShader> paths = _getShaderRelativePathList(
    config.rootPath,
    config.shaders,
    config.exclude,
  );
  paths.sort(((a, b) => a.path.compareTo(b.path)));
  final List<_Statement?> results = await Future.wait(
    paths
        .map(
          (shaderPath) => ShaderType(
            rootPath: config.rootPath,
            path: shaderPath.path,
            flavors: shaderPath.flavors,
          ),
        )
        .mapToUniqueShaderType(style)
        .map(
          (e) => _createShaderTypeStatement(
            config,
            e,
          ),
        ),
  );
  final statements = results.whereType<_Statement>().toList();
  final className = config.flutterGen.shaders.outputs.className;
  final String? packageName = generateShadersPackageNameForConfig(config);
  return _flatStyleShadersClassDefinition(className, statements, packageName);
}

String _flatStyleShadersClassDefinition(
  String className,
  List<_Statement> statements,
  String? packageName,
) {
  final statementsBlock =
      statements.map((statement) => '''${statement.toDartDocString()}
           ${statement.toStaticFieldString()}
           ''').join('\n');
  final valuesBlock = _shaderValuesDefinition(statements, static: true);
  return _shadersClassDefinition(
    className,
    statements,
    statementsBlock,
    valuesBlock,
    packageName,
  );
}

String _dotDelimiterStyleShadersClassDefinition(
  String className,
  List<_Statement> statements,
  String? packageName,
) {
  final statementsBlock =
      statements.map((statement) => statement.toStaticFieldString()).join('\n');
  final valuesBlock = _shaderValuesDefinition(statements, static: true);
  return _shadersClassDefinition(
    className,
    statements,
    statementsBlock,
    valuesBlock,
    packageName,
  );
}

String _shaderValuesDefinition(
  List<_Statement> statements, {
  bool static = false,
}) {
  final values = statements.where((element) => !element.isDirectory);
  if (values.isEmpty) return '';
  final names = values.map((value) => value.name).join(', ');
  final type = values.every((element) => element.type == values.first.type)
      ? values.first.type
      : 'dynamic';

  return '''
  /// List of all shaders
  ${static ? 'static ' : ''}List<$type> get values => [$names];''';
}

String _shadersClassDefinition(
  String className,
  List<_Statement> statements,
  String statementsBlock,
  String valuesBlock,
  String? packageName,
) {
  return '''
class $className {
  $className._();
${packageName != null ? "\n  static const String package = '$packageName';" : ''}

  $statementsBlock
  $valuesBlock
}
''';
}

String _directoryClassGenDefinition(
  String className,
  List<_Statement> statements,
  String? directoryPath,
) {
  final statementsBlock = statements.map((statement) {
    final buffer = StringBuffer();
    if (statement.needDartDoc) {
      buffer.writeln(statement.toDartDocString());
    }
    buffer.writeln(statement.toGetterString());
    return buffer.toString();
  }).join('\n');
  final pathBlock = directoryPath != null
      ? '''
  /// Directory path: $directoryPath
  String get path => '$directoryPath';
'''
      : '';
  final valuesBlock = _shaderValuesDefinition(statements);

  return '''
class $className {
  const $className();
  
  $statementsBlock
  $pathBlock
  $valuesBlock
}
''';
}

/// The generated statement for each shader, e.g
/// '$type get $name => ${isConstConstructor ? 'const' : ''} $value;';
class _Statement {
  const _Statement({
    required this.type,
    required this.filePath,
    required this.name,
    required this.value,
    required this.isConstConstructor,
    required this.isDirectory,
    required this.needDartDoc,
  });

  /// The type of this shader, e.g ShaderGenImage, SvgGenImage, String, etc.
  final String type;

  /// The relative path of this shader from the root directory.
  final String filePath;

  /// The variable name of this shader.
  final String name;

  /// The code to instantiate this shader. e.g `ShaderGenImage('shaders/image.png');`
  final String value;

  final bool isConstConstructor;
  final bool isDirectory;
  final bool needDartDoc;

  String toDartDocString() => '/// File path: $filePath';

  String toGetterString() {
    final buffer = StringBuffer('');
    if (isDirectory) {
      buffer.writeln(
        '/// Directory path: '
        '${Directory(filePath).path.replaceAll(r'\', r'/')}',
      );
    }
    buffer.writeln(
      '$type get $name => ${isConstConstructor ? 'const' : ''} $value;',
    );
    return buffer.toString();
  }

  String toStaticFieldString() => 'static const $type $name = $value;';
}
