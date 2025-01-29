import 'package:collection/collection.dart';
import 'package:flutter_gen_core/settings/import.dart';

String get header {
  return '''/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

''';
}

String get ignore {
  return '''// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use
  
''';
}

String import(Import package) {
  return 'import \'${package.import}\''
      '${package.alias != null ? ' as ${package.alias}' : ''};';
}

const sDeprecationHeader = '''
                                                                                        
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
                                                                                        
                                                                                        
                  ░░''';

String sBuildDeprecation(
  String deprecated,
  String oldLocation,
  String newLocation,
  String url,
  List<String> migration,
) {
  final lines = <String>[
    '⚠️ Error',
    'The $deprecated option has been moved from `$oldLocation` to `$newLocation`.',
    'It should be changed in the `pubspec.yaml`.',
    url,
    '',
    '```yaml',
    'flutter_gen:',
    ...migration,
    '```',
  ];

  final longestLineLength = lines
      .map(
        (line) => line
            .split('\n')
            .sorted((a, b) => b.length.compareTo(b.length))
            .first
            .length,
      )
      .sorted((a, b) => b.compareTo(a))
      .first;

  final buffer = StringBuffer();
  buffer.writeln('┌${'─' * (longestLineLength + 2)}┐');
  for (final line in lines) {
    buffer.writeln('| ${line.padRight(longestLineLength)} |');
  }
  buffer.writeln('└${'─' * (longestLineLength + 2)}┘');
  return buffer.toString();
}
